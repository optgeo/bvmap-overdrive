# bvmap-overdrive Justfile
# Convert GSI optimal vector tiles from MVT to MLT format

# Configuration
input_url := "https://cyberjapandata.gsi.go.jp/xyz/optimal_bvmap-v1/optimal_bvmap-v1.pmtiles"
input_pmtiles := "optimal_bvmap-v1.pmtiles"
mvt_mbtiles := "bvmap-mvt.mbtiles"
mlt_mbtiles := "bvmap-mlt.mbtiles"
output_pmtiles := "bvmap-overdrive.pmtiles"

# go-pmtiles version and URL
go_pmtiles_version := "1.28.2"
go_pmtiles_url := "https://github.com/protomaps/go-pmtiles/releases/download/v" + go_pmtiles_version + "/go-pmtiles_" + go_pmtiles_version + "_Linux_x86_64.tar.gz"

# mlt-encode.jar version and URL
mlt_version := "java-v0.0.4"
mlt_encode_url := "https://github.com/maplibre/maplibre-tile-spec/releases/download/" + mlt_version + "/mlt-encode.jar"

# Upload destination
upload_user := "pod"
upload_host := "pod.local"
upload_path := "/home/pod/x-24b/data"
upload_target := upload_user + "@" + upload_host + ":" + upload_path

# Default task: show help
default:
    @just --list

# Run all conversion steps
doit: download fetch pmtiles2mbtiles mbtiles2mlt mlt2pmtiles
    @echo "Conversion complete: {{output_pmtiles}}"

# Download dependency tools
download: _download_pmtiles_cli _download_mlt_encode

# Download go-pmtiles CLI
_download_pmtiles_cli:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "pmtiles" ]; then
        echo "Downloading go-pmtiles..."
        aria2c -o go-pmtiles.tar.gz "{{go_pmtiles_url}}"
        tar -xzf go-pmtiles.tar.gz pmtiles
        rm go-pmtiles.tar.gz
        chmod +x pmtiles
        echo "go-pmtiles download complete"
    else
        echo "go-pmtiles already exists"
    fi

# Download mlt-encode.jar
_download_mlt_encode:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "mlt-encode.jar" ]; then
        echo "Downloading mlt-encode.jar..."
        aria2c -o mlt-encode.jar "{{mlt_encode_url}}"
        echo "mlt-encode.jar download complete"
    else
        echo "mlt-encode.jar already exists"
    fi

# Download GSI PMTiles
fetch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{input_pmtiles}}" ]; then
        echo "Downloading GSI PMTiles..."
        aria2c -o "{{input_pmtiles}}" "{{input_url}}"
        echo "Download complete: {{input_pmtiles}}"
    else
        echo "{{input_pmtiles}} already exists"
    fi

# Convert PMTiles to MBTiles
pmtiles2mbtiles:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Converting PMTiles to MBTiles..."
    if [ ! -f "{{input_pmtiles}}" ]; then
        echo "Error: Input file {{input_pmtiles}} does not exist. Run fetch task first." >&2
        exit 1
    fi
    tile-join -f -o "{{mvt_mbtiles}}" "{{input_pmtiles}}"
    echo "Conversion complete: {{mvt_mbtiles}}"

# Convert MVT MBTiles to MLT MBTiles
#
# MLT Encoding Parameters for Martin Tile Server Compatibility:
# =============================================================
#
# --tessellate:
#   Enables polygon tessellation for efficient GPU rendering.
#   This is essential for future MLT mainstreaming with WebGL/WebGPU APIs.
#   Reference: https://maplibre.org/maplibre-tile-spec/
#
# --outlines ALL:
#   Generates outlines for all polygon features.
#   Improves rendering quality for vector tile visualization.
#   Reference: https://github.com/maplibre/maplibre-tile-spec
#
# --compress=gzip:
#   CRITICAL: Uses gzip compression instead of deflate.
#   
#   Martin tile server compatibility requirements:
#   - PMTiles v3 spec supports: Unknown(0), None(1), Gzip(2), Brotli(3), Zstd(4)
#   - Martin ONLY supports: None or Gzip for internal tile compression
#   - Deflate is NOT supported by Martin and causes hosting errors
#   
#   Gzip was chosen over "none" because:
#   1. Significant file size reduction (important for web delivery)
#   2. Gzip is widely supported by all browsers and CDNs
#   3. Martin can serve gzip-compressed tiles directly without recompression
#   4. Better compression ratio than raw/uncompressed tiles
#   
#   References:
#   - PMTiles compression enum: https://pmtiles.io/typedoc/enums/Compression.html
#   - Martin CLI docs: https://maplibre.org/martin/run-with-cli.html
#   - Martin compression issue: https://github.com/maplibre/martin/issues/577
#   - PMTiles spec v3: https://github.com/protomaps/PMTiles/blob/main/spec/v3/spec.md
#
# --coerce-mismatch:
#   Allows coercion of property values when type mismatches occur.
#   
#   GSI optimal vector tiles contain properties with inconsistent types across features.
#   For example, the 'vt_arrngagl' property in the 'Anno' layer has both INT_32 and DOUBLE
#   values across different features. Without this flag, mlt-encode.jar throws:
#     java.lang.RuntimeException: Layer 'Anno' Feature index 280 Property 'vt_arrngagl'
#     has different type: INT_32 / DOUBLE
#   
#   This parameter enables type coercion, allowing the encoder to unify these types
#   (typically promoting to the wider type, e.g., INT_32 -> DOUBLE).
#   
#   Reference: https://github.com/maplibre/maplibre-tile-spec (java/mlt-cli/Encode.java)
#
mbtiles2mlt:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Converting MVT to MLT..."
    if [ ! -f "mlt-encode.jar" ]; then
        echo "Error: mlt-encode.jar does not exist. Run download task first." >&2
        exit 1
    fi
    if [ ! -f "{{mvt_mbtiles}}" ]; then
        echo "Error: {{mvt_mbtiles}} does not exist. Run pmtiles2mbtiles task first." >&2
        exit 1
    fi
    java -jar mlt-encode.jar \
        --mbtiles "{{mvt_mbtiles}}" \
        --mlt "{{mlt_mbtiles}}" \
        --tessellate \
        --outlines ALL \
        --compress=gzip \
        --coerce-mismatch \
        --verbose
    echo "Conversion complete: {{mlt_mbtiles}}"

# Convert MLT MBTiles to PMTiles
mlt2pmtiles:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Converting MBTiles(MLT) to PMTiles..."
    if [ ! -f "./pmtiles" ]; then
        echo "Error: pmtiles binary not found. Please download or build it." >&2
        exit 1
    fi
    if [ ! -f "{{mlt_mbtiles}}" ]; then
        echo "Error: Input MBTiles file '{{mlt_mbtiles}}' not found." >&2
        exit 1
    fi
    ./pmtiles convert "{{mlt_mbtiles}}" "{{output_pmtiles}}"
    echo "Conversion complete: {{output_pmtiles}}"

# Upload result to server
upload:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Uploading: {{output_pmtiles}} to {{upload_target}}"
    rsync -avz --progress "{{output_pmtiles}}" "{{upload_target}}"
    echo "Upload complete"

# Remove intermediate files
clean:
    rm -f "{{mvt_mbtiles}}" "{{mlt_mbtiles}}"
    @echo "Intermediate files removed"

# Remove all files (including downloaded tools and input files)
clean-all: clean
    rm -f "{{input_pmtiles}}" "{{output_pmtiles}}" pmtiles mlt-encode.jar
    @echo "All files removed"

# Show PMTiles info
show-info file:
    ./pmtiles show "{{file}}"

# bvmap-overdrive

A project to convert GSI (Geospatial Information Authority of Japan) optimal vector tiles from MVT (Mapbox Vector Tiles) to MLT (MapLibre Tiles) format, creating bvmap-overdrive.pmtiles.

## Overview

GSI optimal vector tiles are processed through the following conversion pipeline:

1. PMTiles (MVT) → MBTiles (MVT) [tile-join]
2. MBTiles (MVT) → MBTiles (MLT) [mlt-encode.jar]
3. MBTiles (MLT) → PMTiles (MLT) [go-pmtiles]

## Data Source

- **Input**: https://cyberjapandata.gsi.go.jp/xyz/optimal_bvmap-v1/optimal_bvmap-v1.pmtiles
- **Output**: bvmap-overdrive.pmtiles

## Prerequisites

The following tools must be installed:

- [just](https://github.com/casey/just) - Command runner
- [aria2c](https://aria2.github.io/) - Download utility
- [tippecanoe](https://github.com/felt/tippecanoe) - Includes tile-join command
- [Java](https://adoptium.net/) - JRE 11 or higher
- [rsync](https://rsync.samba.org/) - File synchronization

## Usage

### Run All Conversion Steps

```bash
just doit
```

This command executes:
1. Download go-pmtiles and mlt-encode.jar (if not already present)
2. Download GSI PMTiles
3. Convert PMTiles to MBTiles
4. Convert MVT to MLT
5. Convert MLT MBTiles to PMTiles

### Upload Result

```bash
just upload
```

Uploads bvmap-overdrive.pmtiles to x-24b server (pod.local).

### Individual Tasks

```bash
just download      # Download dependency tools
just fetch         # Download input PMTiles
just pmtiles2mbtiles  # Convert PMTiles to MBTiles
just mbtiles2mlt   # Convert MVT to MLT
just mlt2pmtiles   # Convert MBTiles(MLT) to PMTiles
just clean         # Remove intermediate files
```

## References

- [MapLibre Tile Spec](https://github.com/maplibre/maplibre-tile-spec) - MLT specification and encoder
- [go-pmtiles](https://github.com/protomaps/go-pmtiles) - PMTiles conversion tool
- [UNopenGIS/7#833](https://github.com/UNopenGIS/7/issues/833) - Project origin issue

## FIXME

- **FIXME2**: Optimal values for mlt-encode.jar options (--tessellate, --outlines, --compress) need validation

## License

MIT License

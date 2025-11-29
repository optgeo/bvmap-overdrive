# bvmap-overdrive Justfile
# PMTiles形式の国土地理院最適化ベクトルタイルをMVTからMLTに変換

# 設定
input_url := "https://cyberjapandata.gsi.go.jp/xyz/optimal_bvmap-v1/optimal_bvmap-v1.pmtiles"
input_pmtiles := "optimal_bvmap-v1.pmtiles"
mvt_mbtiles := "bvmap-mvt.mbtiles"
mlt_mbtiles := "bvmap-mlt.mbtiles"
output_pmtiles := "bvmap-overdrive.pmtiles"

# go-pmtiles バージョンとURL
go_pmtiles_version := "1.28.2"
go_pmtiles_url := "https://github.com/protomaps/go-pmtiles/releases/download/v" + go_pmtiles_version + "/go-pmtiles_" + go_pmtiles_version + "_Linux_x86_64.tar.gz"

# mlt-encode.jar バージョンとURL
mlt_version := "java-v0.0.4"
mlt_encode_url := "https://github.com/maplibre/maplibre-tile-spec/releases/download/" + mlt_version + "/mlt-encode.jar"

# アップロード先 (FIXME1: パスの確認が必要)
upload_host := "tunnel.optgeo.org"
upload_path := "/x-24b/"

# デフォルトタスク: ヘルプ表示
default:
    @just --list

# すべての変換を実行
doit: download fetch pmtiles2mbtiles mbtiles2mlt mlt2pmtiles
    @echo "変換完了: {{output_pmtiles}}"

# 依存ツールのダウンロード
download: _download_pmtiles_cli _download_mlt_encode

# go-pmtiles CLIをダウンロード
_download_pmtiles_cli:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "pmtiles" ]; then
        echo "go-pmtiles をダウンロード中..."
        aria2c -o go-pmtiles.tar.gz "{{go_pmtiles_url}}"
        tar -xzf go-pmtiles.tar.gz pmtiles
        rm go-pmtiles.tar.gz
        chmod +x pmtiles
        echo "go-pmtiles ダウンロード完了"
    else
        echo "go-pmtiles は既に存在します"
    fi

# mlt-encode.jar をダウンロード
_download_mlt_encode:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "mlt-encode.jar" ]; then
        echo "mlt-encode.jar をダウンロード中..."
        aria2c -o mlt-encode.jar "{{mlt_encode_url}}"
        echo "mlt-encode.jar ダウンロード完了"
    else
        echo "mlt-encode.jar は既に存在します"
    fi

# 国土地理院PMTilesをダウンロード
fetch:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{input_pmtiles}}" ]; then
        echo "国土地理院PMTilesをダウンロード中..."
        aria2c -o "{{input_pmtiles}}" "{{input_url}}"
        echo "ダウンロード完了: {{input_pmtiles}}"
    else
        echo "{{input_pmtiles}} は既に存在します"
    fi

# PMTilesをMBTilesに変換
pmtiles2mbtiles:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "PMTiles → MBTiles 変換中..."
    tile-join -f -o "{{mvt_mbtiles}}" "{{input_pmtiles}}"
    echo "変換完了: {{mvt_mbtiles}}"

# MVT MBTilesをMLT MBTilesに変換
# FIXME2: オプション（--tesselate, --outlines, --compress）の最適値を検証する
mbtiles2mlt:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "MVT → MLT 変換中..."
    java -jar mlt-encode.jar \
        --mbtiles "{{mvt_mbtiles}}" \
        --mlt "{{mlt_mbtiles}}" \
        --tessellate \
        --outlines ALL \
        --compress=deflate \
        --verbose
    echo "変換完了: {{mlt_mbtiles}}"

# MLT MBTilesをPMTilesに変換
mlt2pmtiles:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "MBTiles(MLT) → PMTiles 変換中..."
    ./pmtiles convert "{{mlt_mbtiles}}" "{{output_pmtiles}}"
    echo "変換完了: {{output_pmtiles}}"

# 結果をアップロード (FIXME1: パスの確認が必要)
upload:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "アップロード中: {{output_pmtiles}} → {{upload_host}}:{{upload_path}}"
    rsync -avz --progress "{{output_pmtiles}}" "{{upload_host}}:{{upload_path}}"
    echo "アップロード完了"

# 中間ファイルを削除
clean:
    rm -f "{{mvt_mbtiles}}" "{{mlt_mbtiles}}"
    @echo "中間ファイルを削除しました"

# すべてのファイルを削除（ダウンロードしたツールと入力ファイルも含む）
clean-all: clean
    rm -f "{{input_pmtiles}}" "{{output_pmtiles}}" pmtiles mlt-encode.jar
    @echo "すべてのファイルを削除しました"

# PMTiles情報を表示
show-info file:
    ./pmtiles show "{{file}}"

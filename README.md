# bvmap-overdrive

PMTiles形式で提供されている国土地理院最適化ベクトルタイル（bvmap）をMVT（Mapbox Vector Tiles）からMLT（MapLibre Tiles）に変換したbvmap-overdrive.pmtilesを作成するプロジェクトです。

## 概要

国土地理院最適化ベクトルタイルを以下の変換パイプラインで処理します：

1. PMTiles (MVT) → MBTiles (MVT) [tile-join]
2. MBTiles (MVT) → MBTiles (MLT) [mlt-encode.jar]
3. MBTiles (MLT) → PMTiles (MLT) [go-pmtiles]

## データソース

- **入力**: https://cyberjapandata.gsi.go.jp/xyz/optimal_bvmap-v1/optimal_bvmap-v1.pmtiles
- **出力**: bvmap-overdrive.pmtiles

## 必要条件

以下のツールがインストールされている必要があります：

- [just](https://github.com/casey/just) - コマンドランナー
- [aria2c](https://aria2.github.io/) - ダウンローダー
- [tippecanoe](https://github.com/felt/tippecanoe) - tile-join コマンドを含む
- [Java](https://adoptium.net/) - JRE 11以上
- [rsync](https://rsync.samba.org/) - ファイル同期

## 使い方

### すべての変換を実行

```bash
just doit
```

このコマンドは以下を実行します：
1. go-pmtiles と mlt-encode.jar をダウンロード（未取得の場合）
2. 国土地理院PMTilesをダウンロード
3. PMTilesをMBTilesに変換
4. MVTからMLTに変換
5. MLT MBTilesをPMTilesに変換

### 結果をアップロード

```bash
just upload
```

x-24bサーバー（tunnel.optgeo.org）にbvmap-overdrive.pmtilesをアップロードします。

### 個別タスク

```bash
just download      # 依存ツールのダウンロード
just fetch         # 入力PMTilesのダウンロード
just pmtiles2mbtiles  # PMTiles→MBTiles変換
just mbtiles2mlt   # MVT→MLT変換
just mlt2pmtiles   # MBTiles(MLT)→PMTiles変換
just clean         # 中間ファイルの削除
```

## 参考情報

- [MapLibre Tile Spec](https://github.com/maplibre/maplibre-tile-spec) - MLT仕様とエンコーダー
- [go-pmtiles](https://github.com/protomaps/go-pmtiles) - PMTiles変換ツール
- [UNopenGIS/7#833](https://github.com/UNopenGIS/7/issues/833) - プロジェクト発起イシュー

## FIXME

- **FIXME1**: tunnel.optgeo.orgへのアップロードパスが未確定（現在は `/x-24b/` と仮定）
- **FIXME2**: mlt-encode.jarのオプション（--tesselate, --outlines, --compress）の最適値が未検証

## ライセンス

MIT License

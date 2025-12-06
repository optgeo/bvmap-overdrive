# bvmap-overdrive Web Viewer

This directory contains a static website for viewing bvmap-overdrive MLT (MapLibre Tiles) vector tiles.

## Features

- **MapLibre GL JS v5.14.0**: Uses the latest version with native MLT support
- **MLT Encoding**: Consumes tiles with `encoding: 'mlt'` parameter
- **GSI Base Map**: Based on GSI Japan's optimal vector tile skeleton style
- **Interactive Controls**: Navigation, geolocation, and scale controls

## Files

- `index.html`: Main HTML page with MapLibre GL JS map viewer
- `style.json`: MapLibre style specification configured for MLT tiles

## Tile Source

The website consumes MLT-encoded vector tiles from:
- **Tiles URL**: `https://tunnel.optgeo.org/martin/bvmap-overdrive/{z}/{x}/{y}`
- **TileJSON**: `https://tunnel.optgeo.org/martin/bvmap-overdrive`

## About MLT

MapLibre Tiles (MLT) is a next-generation vector tile format that provides:
- Better compression and decoding performance
- Support for advanced data types (e.g., M-values for elevation)
- Direct-to-GPU vertex data for efficient rendering
- Tessellated polygons for WebGL/WebGPU optimization

The tiles are served by Martin tile server, which disguises MLT tiles as MVT for compatibility, but MapLibre GL JS correctly interprets them as MLT when `encoding: 'mlt'` is specified.

## References

- [MapLibre GL JS Documentation](https://maplibre.org/maplibre-gl-js/docs/)
- [MapLibre Tile Specification](https://maplibre.org/maplibre-tile-spec/)
- [GSI Optimal Vector Tiles](https://github.com/gsi-cyberjapan/optimal_bvmap)
- [Martin Tile Server](https://github.com/maplibre/martin)

## GitHub Pages

This site is hosted via GitHub Pages from the `/docs` directory.

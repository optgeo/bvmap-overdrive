# bvmap-overdrive Web Viewer

This directory contains a static website for viewing bvmap-overdrive MLT (MapLibre Tiles) vector tiles.

## Features

- **MapLibre GL JS v5.14.0**: Uses the latest version with native MLT support
- **MLT Encoding**: Consumes tiles with `encoding: 'mlt'` parameter
- **Multiple Styles**: Switch between Standard (std) and Skeleton styles via dropdown menu
- **3D Terrain**: Fusi terrarium tiles with hillshade and 3D visualization (exaggeration: 1.0)
- **Globe Projection**: MapLibre GL JS native GlobeControl for globe view
- **Mobile Optimized**: Info panel automatically minimized on mobile devices
- **Interactive Controls**: Navigation with pitch visualization, geolocation, scale, and globe controls

## Files

- `index.html`: Main HTML page with MapLibre GL JS map viewer
- `skeleton.json`: MapLibre skeleton style (minimal) configured for MLT tiles
- `std.json`: MapLibre standard style (detailed) configured for MLT tiles

## Tile Source

The website consumes MLT-encoded vector tiles from:
- **Tiles URL**: `https://tunnel.optgeo.org/martin/bvmap-overdrive/{z}/{x}/{y}`
- **TileJSON**: `https://tunnel.optgeo.org/martin/bvmap-overdrive`

The website also uses Fusi terrarium elevation tiles for 3D terrain and hillshade:
- **Terrain Tiles**: `https://tunnel.optgeo.org/martin/fusi/{z}/{x}/{y}`
- **Encoding**: Terrarium format (RGB-encoded elevation data)

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
- [Fusi Terrarium Tiles](https://github.com/hfu/fusite2)

## GitHub Pages

This site is hosted via GitHub Pages from the `/docs` directory.

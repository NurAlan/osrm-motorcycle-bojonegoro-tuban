# Contributing

Contributions are welcome. Please open an issue before large behavior changes so the motorcycle access rules and supported region can be discussed.

## Local checks

```bash
python3 -m unittest discover -s tests -v
docker compose -f compose.yaml config --quiet
```

## Data and build artifacts

Do not commit OSM `.pbf` extracts, generated `.osrm*` files, image archives, credentials, or user data. The Dockerfile downloads the pinned Geofabrik source, verifies its MD5 sidecar, clips the configured region, and builds the routing graph in intermediate stages.

## Routing profile changes

Keep motorcycle access tags ahead of generic vehicle tags, retain the no-toll/motorway policy unless explicitly discussed, and add or update tests when changing those rules. Confirm that new profile behavior is compatible with the pinned OSRM release.

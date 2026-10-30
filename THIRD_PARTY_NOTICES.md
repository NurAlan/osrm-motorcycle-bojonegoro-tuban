# Third-party notices

## Project OSRM

The custom `profiles/motorcycle.lua` profile is derived from OSRM's `profiles/car.lua` and adapted for motorcycle access and toll-road avoidance. OSRM is Copyright (c) 2017 Project OSRM contributors and distributed under BSD 2-Clause; the full upstream license text is in [`LICENSE.OSRM`](LICENSE.OSRM).

- Source: <https://github.com/Project-OSRM/osrm-backend/blob/v26.10.0/profiles/car.lua>
- Project: <https://github.com/Project-OSRM/osrm-backend>
- License identifier: BSD-2-Clause
- Runtime image is based on `ghcr.io/project-osrm/osrm-backend`, also BSD-2-Clause.

## OpenStreetMap data

The routing graph is built from OpenStreetMap data downloaded as a Geofabrik regional extract. OpenStreetMap contributors' data is licensed under the Open Data Commons Open Database License (ODbL) 1.0. Attribution is required when publicly using the data and derivative databases must follow the applicable share-alike obligations.

Required public attribution:

> © OpenStreetMap contributors. Data available under the Open Database License (ODbL) at <https://www.openstreetmap.org/copyright>.

Data source used by the default build: <https://download.geofabrik.de/asia/indonesia/java-261029.osm.pbf>.
The raw extract is fetched during the Docker build and is not included in the final runtime image or this source repository. The OSRM routing graph in the image is derived from that data.

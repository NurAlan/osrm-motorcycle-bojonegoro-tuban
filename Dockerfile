# Build a small, self-contained OSRM image. OSM downloads and graph data stay
# in intermediate stages and are not copied into the final runtime image.
ARG OSRM_IMAGE=ghcr.io/project-osrm/osrm-backend:latest@sha256:55dbfd47d984c2cacd64e32901b4321c86b5ec761438e69aa053dc78698a786f

FROM debian:bookworm-slim AS osm-extract
ARG OSM_PBF_URL=https://download.geofabrik.de/asia/indonesia/java-261029.osm.pbf
ARG OSM_PBF_MD5_URL=https://download.geofabrik.de/asia/indonesia/java-261029.osm.pbf.md5
ARG OSM_PBF_FILENAME=java-261029.osm.pbf
ARG REGION_BBOX=111.25,-7.65,112.55,-6.45
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl osmium-tool \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp/osm
RUN set -eux; \
    curl --fail --location --show-error --connect-timeout 30 --max-time 1800 --retry 5 --retry-delay 5 --retry-all-errors \
      "$OSM_PBF_URL" -o "$OSM_PBF_FILENAME"; \
    curl --fail --location --show-error --connect-timeout 30 --max-time 120 --retry 5 --retry-delay 5 --retry-all-errors \
      "$OSM_PBF_MD5_URL" -o "$OSM_PBF_FILENAME.md5"; \
    md5sum -c "$OSM_PBF_FILENAME.md5"; \
    mkdir -p /data; \
    osmium extract --bbox "$REGION_BBOX" --strategy complete_ways \
      "$OSM_PBF_FILENAME" -o /data/bojonegoro-tuban.osm.pbf --overwrite; \
    rm -f "$OSM_PBF_FILENAME" "$OSM_PBF_FILENAME.md5"

FROM ${OSRM_IMAGE} AS graph-builder
# The bundled Lua profile libraries resolve relative to /opt.
WORKDIR /opt
COPY profiles/motorcycle.lua /opt/custom-profiles/motorcycle.lua
COPY --from=osm-extract /data/bojonegoro-tuban.osm.pbf /data/bojonegoro-tuban.osm.pbf
RUN osrm-extract -p /opt/custom-profiles/motorcycle.lua /data/bojonegoro-tuban.osm.pbf -o /data/bojonegoro-tuban-motorcycle.osrm \
    && osrm-partition /data/bojonegoro-tuban-motorcycle.osrm \
    && osrm-customize /data/bojonegoro-tuban-motorcycle.osrm \
    && rm -f /data/*.osm.pbf

FROM ${OSRM_IMAGE} AS runtime
LABEL org.opencontainers.image.title="OSRM Motorcycle Router" \
      org.opencontainers.image.source="https://github.com/NurAlan/osrm-motorcycle-router" \
      org.opencontainers.image.licenses="BSD-2-Clause"
COPY --from=graph-builder /data/ /data/
COPY LICENSE /usr/share/licenses/osrm-motorcycle-router/LICENSE
COPY LICENSE.OSRM /usr/share/licenses/osrm-motorcycle-router/LICENSE.OSRM
COPY THIRD_PARTY_NOTICES.md /usr/share/doc/osrm-motorcycle-router/THIRD_PARTY_NOTICES.md
EXPOSE 5000
ENTRYPOINT ["osrm-routed", "--algorithm", "mld", "--max-table-size", "10000", "/data/bojonegoro-tuban-motorcycle.osrm"]

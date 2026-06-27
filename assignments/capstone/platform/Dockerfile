# Capstone — production image (multi-stage, pinned, non-root, healthchecked). See README.md.
#
# TODO: a build stage (FROM <pinned> AS build) and a runtime stage (FROM <pinned> AS runtime):
#   - pinned, slim base (not :latest)
#   - npm ci (build) / npm ci --omit=dev or NODE_ENV=production (runtime)
#   - COPY --from=build the artifact only
#   - USER node, HEALTHCHECK, no baked secrets

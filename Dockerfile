ARG TF_VERSION="1.1.0"

FROM --platform=$BUILDPLATFORM alpine:3.15 as terraform
SHELL ["/bin/sh", "-cex"]
ARG TARGETOS TARGETARCH
RUN wget -O tf.zip 'https://releases.hashicorp.com/terraform/'${TF_VERSION}'/terraform_'${TF_VERSION}'_'${TARGETOS}'_'${TARGETARCH}'.zip'; \
  unzip tf.zip

FROM --platform=$BUILDPLATFORM crazymax/goreleaser-xx:latest AS goreleaser-xx
FROM --platform=$BUILDPLATFORM pratikimprowise/upx:3.96 AS upx
FROM --platform=$BUILDPLATFORM golang:1.17-alpine AS base
COPY --from=goreleaser-xx / /
COPY --from=upx / /
ENV CGO_ENABLED=0
RUN apk --update add --no-cache git ca-certificates && \
  update-ca-certificates
WORKDIR /src

FROM base AS vendored
RUN --mount=type=bind,target=.,rw \
  --mount=type=cache,target=/go/pkg/mod \
  go mod tidy && go mod download

FROM vendored AS binary
ARG TARGETPLATFORM
COPY --from=ui /src/dist /src/ui/dist
COPY . .
RUN --mount=type=cache,target=/root/.cache \
  --mount=type=cache,target=/go/pkg/mod \
  goreleaser-xx --debug \
    --name="rover" \
    --main="." \
    --dist="/out" \
    --artifacts="bin" \
    --snapshot="no" \
    --post-hooks="sh -cx 'upx --ultra-brute --best /usr/local/bin/rover || true'"

FROM --platform=$BUILDPLATFORM node:16-alpine as ui
WORKDIR /src
COPY ./ui/package*.json ./
RUN npm set progress=false && npm config set depth 0 && npm install
COPY ./ui/public ./public
COPY ./ui/src ./src
RUN npm run build

FROM scratch as release
WORKDIR /tmp
WORKDIR /src
COPY --from=terraform /terraform           /usr/local/bin/terraform
COPY --from=base      /etc/ssl/certs/      /etc/ssl/certs/
COPY --from=binary    /usr/local/bin/rover /usr/local/bin/rover
ENTRYPOINT ["/usr/local/bin/rover"]

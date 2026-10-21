# syntax=docker/dockerfile:1

# Keep the builder aligned with the version declared in go.mod.
ARG GO_VERSION=1.27.2

# Build on the native builder platform and cross-compile for the target image.
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine3.24 AS build

WORKDIR /src

# Download dependencies before copying source code so this layer remains cached
# when application code changes but go.mod and go.sum do not.
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download && go mod verify

COPY . .

ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/crystaloop .

# The runtime image contains no shell or package manager and runs as non-root.
FROM gcr.io/distroless/static-debian13:nonroot AS runtime

WORKDIR /app

COPY --from=build --chown=nonroot:nonroot /out/crystaloop ./crystaloop

# Hertz listens on :8888 by default. EXPOSE documents the container port; the
# deployment still needs to publish or map it explicitly.
EXPOSE 8888

USER nonroot:nonroot
ENTRYPOINT ["/app/crystaloop"]

# CrystaLoop

[![Go 1.27.2](https://img.shields.io/badge/Go-1.27.2-00ADD8?logo=go&logoColor=white)](go.mod)

[English](README.md) · [简体中文](docs/README.zh-CN.md)

A small, transparent Go project for learning how AI agent loops are built from the ground up.

> **Project status:** CrystaLoop is at the scaffold stage. It currently provides a working HTTP service and development workflow; an agent loop has not been implemented yet.

## Quick start

You need **Go 1.27.2** (as specified in `go.mod`) and **Make**.

```sh
make deps
make run
```

The service listens on `http://localhost:8888` by default. In another terminal:

```sh
curl http://localhost:8888/ping
# {"message":"pong"}

curl 'http://localhost:8888/hello?name=World'
# {"message":"Hello, World!"}
```

## What works today

| Endpoint | Description | Response |
| --- | --- | --- |
| `GET /ping` | Basic service check | `200` · `{"message":"pong"}` |
| `GET /hello?name=World` | Greet the supplied name | `200` · `{"message":"Hello, World!"}` |

The `name` query parameter is required for `/hello`; omitting it returns `400 Bad Request` with a validation error.

The HTTP service uses [Hertz](https://github.com/cloudwego/hertz). The hello endpoint is defined in [`api/hello/hello.thrift`](api/hello/hello.thrift); Hertz generates its DTOs and routes under `internal/trigger/`. The current endpoints are examples for the scaffold, not agent capabilities.

## Development

| Command | Purpose |
| --- | --- |
| `make setup` | Install pinned `hz` and `thriftgo` tools and download Go modules. |
| `make generate` | Regenerate Hertz code after changing the Thrift IDL. |
| `make run` | Run the service from source. |
| `make check` | Check formatting, verify modules, run `go vet` and tests. |
| `make build` | Write the binary to `output/`. |

Run `make help` for the full list of targets. Files marked as generated may be overwritten by `make generate`.

## Docker

```sh
docker build -t crystaloop .
docker run --rm -p 8888:8888 crystaloop
```

Or use Docker Compose to build and run the service:

```sh
docker compose up --build
```

The Compose service runs with a read-only root filesystem, no Linux
capabilities, and an ephemeral `/tmp` directory. Set `CRYSTALOOP_PORT` to
publish the service on a different local port (for example,
`CRYSTALOOP_PORT=8080 docker compose up --build`).

The [CI workflow](.github/workflows/ci.yml) runs the Go checks and build, then builds and smoke-tests the container image through `/ping`.

## License

CrystaLoop is licensed under the [MIT License](LICENSE).

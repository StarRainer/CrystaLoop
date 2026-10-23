# CrystaLoop

[![Go 1.27.2](https://img.shields.io/badge/Go-1.27.2-00ADD8?logo=go&logoColor=white)](../go.mod)

[English](../README.md) · [简体中文](README.zh-CN.md)

一个从零开始、力求清晰易懂的 Go 项目，用于学习 AI Agent 循环是如何构建的。

> **项目状态：** CrystaLoop 目前仍处于模板搭建阶段。仓库已有可运行的 HTTP 服务和开发工作流；Agent 循环尚未实现。

## 快速开始

需要安装 **Go 1.27.2**（与 `go.mod` 一致）和 **Make**。

```sh
make deps
make run
```

服务默认监听 `http://localhost:8888`。在另一个终端中试试：

```sh
curl http://localhost:8888/ping
# {"message":"pong"}

curl 'http://localhost:8888/hello?name=World'
# {"message":"Hello, World!"}
```

## 当前已实现

| 接口 | 用途 | 响应 |
| --- | --- | --- |
| `GET /ping` | 检查服务是否正常运行 | `200` · `{"message":"pong"}` |
| `GET /hello?name=World` | 根据传入的名字返回问候语 | `200` · `{"message":"Hello, World!"}` |

`/hello` 的 `name` 查询参数为必填项；缺少该参数时会返回 `400 Bad Request` 和校验错误信息。

HTTP 服务使用 [Hertz](https://github.com/cloudwego/hertz)。Hello 接口定义在 [`api/hello/hello.thrift`](../api/hello/hello.thrift)，Hertz 根据 IDL 在 `internal/trigger/` 下生成 DTO 和路由。当前接口用于演示项目模板，并非 Agent 功能。

## 开发

| 命令 | 用途 |
| --- | --- |
| `make setup` | 安装固定版本的 `hz`、`thriftgo`，并下载 Go 模块。 |
| `make generate` | 修改 Thrift IDL 后重新生成 Hertz 代码。 |
| `make run` | 从源码启动服务。 |
| `make check` | 检查格式、验证模块，并运行 `go vet` 和测试。 |
| `make build` | 将可执行文件构建到 `output/`。 |

运行 `make help` 可查看全部命令。标记为生成代码的文件可能被 `make generate` 覆盖。

## Docker

```sh
docker build -t crystaloop .
docker run --rm -p 8888:8888 crystaloop
```

[CI 工作流](../.github/workflows/ci.yml)会执行 Go 检查与构建，然后构建容器镜像，并通过 `/ping` 进行冒烟测试。

## 许可证

CrystaLoop 使用 [MIT License](../LICENSE)。

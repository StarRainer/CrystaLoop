.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

# Project settings. Override from the command line when needed, for example:
# make build APP_NAME=crystaloop-dev
APP_NAME ?= crystaloop
OUTPUT_DIR ?= output
PACKAGES ?= ./...

# Toolchain settings.
GO ?= go
HZ ?= hz
HZ_VERSION ?= v0.9.7

# Hertz code-generation settings. Router output is configured in .hz.
IDL ?= api/hello/hello.thrift
HANDLER_DIR ?= internal/trigger/http/handler
MODEL_DIR ?= internal/trigger/dto

# Derived artifact paths.
BINARY_EXT :=
ifeq ($(OS),Windows_NT)
BINARY_EXT := .exe
endif
BINARY := $(OUTPUT_DIR)/$(APP_NAME)$(BINARY_EXT)
COVERAGE_FILE := $(OUTPUT_DIR)/coverage.out

.PHONY: help all deps tools generate fmt fmt-check tidy verify vet test coverage build run check ci clean

help: ## Show available targets.
	@printf '%s\n' \
		'Usage: make <target>' \
		'' \
		'Targets:' \
		'  all         Run checks and build the application.' \
		'  deps        Download Go module dependencies.' \
		'  tools       Install the pinned Hertz code generator.' \
		'  generate    Regenerate Hertz code from the Thrift IDL.' \
		'  fmt         Format all Go packages.' \
		'  fmt-check   Fail when tracked Go files are not formatted.' \
		'  tidy        Synchronize go.mod and go.sum.' \
		'  verify      Verify downloaded module dependencies.' \
		'  vet         Run go vet.' \
		'  test        Run all tests.' \
		'  coverage    Run tests and write an HTML-ready coverage profile.' \
		'  build       Build the application into output/.' \
		'  run         Run the application locally.' \
		'  check       Run formatting, module, vet, and test checks.' \
		'  ci          Run checks and build the application.' \
		'  clean       Remove generated build and coverage artifacts.'

all: check build

deps:
	$(GO) mod download

tools:
	$(GO) install github.com/cloudwego/hertz/cmd/hz@$(HZ_VERSION)

generate:
	$(HZ) update \
		--idl "$(IDL)" \
		--handler_dir "$(HANDLER_DIR)" \
		--model_dir "$(MODEL_DIR)" \
		--sort_router

fmt:
	$(GO) fmt $(PACKAGES)

fmt-check:
	@files="$$(gofmt -l $$(git ls-files '*.go'))"; \
	if [ -n "$$files" ]; then \
		printf '%s\n' 'The following Go files need formatting:' "$$files"; \
		exit 1; \
	fi

tidy:
	$(GO) mod tidy

verify:
	$(GO) mod verify

vet:
	$(GO) vet $(PACKAGES)

test:
	$(GO) test $(PACKAGES)

coverage: | $(OUTPUT_DIR)
	$(GO) test -coverprofile="$(COVERAGE_FILE)" $(PACKAGES)
	$(GO) tool cover -func="$(COVERAGE_FILE)"

build: | $(OUTPUT_DIR)
	$(GO) build -o "$(BINARY)" .

run:
	$(GO) run .

check: fmt-check verify vet test

ci: check build

clean:
	$(RM) "$(BINARY)" "$(COVERAGE_FILE)"

$(OUTPUT_DIR):
	mkdir -p "$@"

.DEFAULT_GOAL := help

# ==============================================================================
# Project configuration
# ==============================================================================
# Variables declared with ?= can be overridden from the command line,
# for example: make build APP_NAME=crystaloop-dev
APP_NAME ?= crystaloop
OUTPUT_DIR ?= output

# Package pattern used by formatting, vet, test, and coverage targets.
PACKAGES ?= ./...

# ==============================================================================
# Toolchain
# ==============================================================================
# Executable names may be overridden when tools are outside PATH.
GO ?= go
HZ ?= hz

# Pin code generators so every developer produces the same output.
HZ_VERSION ?= v0.9.7
THRIFT_GO_VERSION ?= v0.4.5

# ==============================================================================
# Hertz code generation
# ==============================================================================
# IDL is the primary Thrift file passed to hz. The namespace declared in the
# IDL is appended to HANDLER_DIR and MODEL_DIR by the generator.
IDL ?= api/hello/hello.thrift
HANDLER_DIR ?= internal/trigger/http/handler
MODEL_DIR ?= internal/trigger/dto

# The router output directory is persisted by hz in the .hz file.

# ==============================================================================
# Build artifacts
# ==============================================================================
# Windows binaries use the .exe suffix; other platforms use no suffix.
BINARY_EXT :=
ifeq ($(OS),Windows_NT)
BINARY_EXT := .exe
endif

BINARY := $(OUTPUT_DIR)/$(APP_NAME)$(BINARY_EXT)
COVERAGE_FILE := $(OUTPUT_DIR)/coverage.out
COVERAGE_HTML := $(OUTPUT_DIR)/coverage.html

# ==============================================================================
# Help
# ==============================================================================
.PHONY: help

help:
	@printf '%s\n' \
		'Usage: make <target>' \
		'' \
		'Common workflow:' \
		'  make setup      Install tools and download dependencies.' \
		'  make generate   Regenerate code after changing the IDL.' \
		'  make run        Start the service locally.' \
		'  make check      Run all non-mutating quality checks.' \
		'  make build      Build the application binary.' \
		'' \
		'Setup:' \
		'  setup           Install pinned tools and download dependencies.' \
		'  tools           Install hz and thriftgo at pinned versions.' \
		'  deps            Download modules declared in go.mod.' \
		'' \
		'Development:' \
		'  generate        Generate models, handlers, and routes from the IDL.' \
		'  run             Run the service from source.' \
		'  fmt             Format all Go packages.' \
		'  tidy            Update go.mod and go.sum to match source imports.' \
		'' \
		'Quality:' \
		'  check           Run fmt-check, verify, vet, and test.' \
		'  fmt-check       Fail if tracked Go files need formatting.' \
		'  verify          Verify downloaded modules against go.sum.' \
		'  vet             Run Go static analysis.' \
		'  test            Run all Go tests.' \
		'  coverage        Run tests and write an HTML coverage report.' \
		'' \
		'Build and CI:' \
		'  build           Build the application into output/.' \
		'  ci              Run quality checks, then build.' \
		'  clean           Remove build and coverage artifacts.'

# ==============================================================================
# Setup
# ==============================================================================
# setup is the single entry point for preparing a new development environment.
.PHONY: setup tools deps

setup: tools deps

tools:
	$(GO) install github.com/cloudwego/hertz/cmd/hz@$(HZ_VERSION)
	$(GO) install github.com/cloudwego/thriftgo@$(THRIFT_GO_VERSION)

deps:
	$(GO) mod download

# ==============================================================================
# Development
# ==============================================================================
# Regenerate all Hertz-owned files after changing the primary IDL. Do not edit
# files marked "Code generated" because the next update will overwrite them.
.PHONY: generate run fmt tidy

generate:
	$(HZ) update \
		--idl "$(IDL)" \
		--handler_dir "$(HANDLER_DIR)" \
		--model_dir "$(MODEL_DIR)" \
		--sort_router

run:
	$(GO) run .

fmt:
	$(GO) fmt $(PACKAGES)

# tidy intentionally remains separate from check because it modifies go.mod and
# go.sum instead of only validating the working tree.
tidy:
	$(GO) mod tidy

# ==============================================================================
# Quality checks
# ==============================================================================
# check is safe for local use and CI: its dependencies do not modify source.
.PHONY: check fmt-check verify vet test coverage

check: fmt-check verify vet test

# Only tracked files are checked so temporary generated files do not create
# unrelated formatting failures.
fmt-check:
	@files="$$(gofmt -l $$(git ls-files '*.go'))"; \
	if [ -n "$$files" ]; then \
		printf '%s\n' 'The following Go files need formatting:' "$$files"; \
		exit 1; \
	fi

verify:
	$(GO) mod verify

vet:
	$(GO) vet $(PACKAGES)

test:
	$(GO) test $(PACKAGES)

# coverage.out is the machine-readable profile consumed by Go tooling.
# coverage.html is the human-readable report that should be opened in a browser.
coverage: | $(OUTPUT_DIR)
	$(GO) test -coverprofile="$(COVERAGE_FILE)" $(PACKAGES)
	$(GO) tool cover -func="$(COVERAGE_FILE)"
	$(GO) tool cover -html="$(COVERAGE_FILE)" -o "$(COVERAGE_HTML)"
	@printf '%s\n' 'Coverage report: $(COVERAGE_HTML)'

# ==============================================================================
# Build and CI
# ==============================================================================
# The order-only prerequisite creates OUTPUT_DIR without making its timestamp
# determine whether the build recipe is out of date.
.PHONY: build ci clean

build: | $(OUTPUT_DIR)
	$(GO) build -o "$(BINARY)" .

ci: check build

# OUTPUT_DIR contains generated artifacts only, so clean removes it completely.
clean:
	$(RM) -r "$(OUTPUT_DIR)"

# ==============================================================================
# Internal targets
# ==============================================================================
# build and coverage use this real directory target as an order-only
# prerequisite. $@ expands to the target name, which is OUTPUT_DIR here.
$(OUTPUT_DIR):
	mkdir -p "$@"

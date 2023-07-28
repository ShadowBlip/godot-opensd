EXT_NAME := opensd
NUM_CPU := $(shell nproc)
GODOT_CPP_FILES := $(shell find ./ -regex  '.*\(cpp\|h\|hpp\)$$') godot-cpp/SConstruct
ALL_CPP := $(shell find ./src -name '*.cpp')
ALL_HEADERS := $(shell find ./src -name '*.h')
RELEASE_TARGET := addons/$(EXT_NAME)/bin/lib$(EXT_NAME).linux.template_release.x86_64.so
DEBUG_TARGET := addons/$(EXT_NAME)/bin/lib$(EXT_NAME).linux.template_debug.x86_64.so

# Docker image variables
#IMAGE_NAME ?= ghcr.io/shadowblip/opengamepadui-builder
#IMAGE_TAG ?= latest
IMAGE_NAME ?= opensd-builder
IMAGE_TAG ?= latest

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build
build: $(RELEASE_TARGET) $(DEBUG_TARGET) compiledb ## Build release and debug binaries

.PHONY: clean
clean:
	rm -rf addons/$(EXT_NAME)/bin
	rm -rf dist

.PHONY: release
release: $(RELEASE_TARGET) ## Build release binary
$(RELEASE_TARGET): $(ALL_HEADERS) $(ALL_CPP) $(GODOT_CPP_FILES)
	scons platform=linux -j$(NUM_CPU) target=template_release

.PHONY: debug
debug: $(DEBUG_TARGET) ## Build binary with debug symbols
$(DEBUG_TARGET): $(ALL_HEADERS) $(ALL_CPP) $(GODOT_CPP_FILES)
	scons platform=linux -j$(NUM_CPU) target=template_debug

##@ Development

.PHONY: compiledb
compiledb: compile_commands.json ## Generate compiledb.json
compile_commands.json: godot-cpp/SConstruct $(ALL_CPP) $(ALL_HEADERS) $(GODOT_CPP_FILES)
	scons -Q compiledb


## Godot CPP

godot-cpp/SConstruct:
	git submodule update --init --recursive

godot-cpp/bin/libgodot-cpp.linux.template_debug.x86_64.a: $(GODOT_CPP_FILES)
	cd godot-cpp && scons platform=linux -j$(NUM_CPU) target=template_debug

godot-cpp/bin/libgodot-cpp.linux.template_release.x86_64.a: $(GODOT_CPP_FILES)
	cd godot-cpp && scons platform=linux -j$(NUM_CPU) target=template_release


##@ Distribution

.PHONY: dist
dist: dist/godot-$(EXT_NAME).tar.gz ## Build a redistributable archive of the project
dist/godot-$(EXT_NAME).tar.gz: $(RELEASE_TARGET) $(DEBUG_TARGET)
	mkdir -p dist
	tar cvfz $@ addons


# Refer to .releaserc.yaml for release configuration
.PHONY: sem-release 
sem-release: ## Publish a release with semantic release 
	npx semantic-release

# E.g. make in-docker TARGET=build
.PHONY: in-docker
in-docker:
	@# Run the given make target inside Docker
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	docker run --rm \
		-v $(PWD):/src \
		--workdir /src \
		-e HOME=/home/build \
		--user $(shell id -u):$(shell id -g) \
		$(IMAGE_NAME):$(IMAGE_TAG) \
		make $(TARGET)

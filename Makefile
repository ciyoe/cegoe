INST_PREFIX ?= /usr
INST_LIBDIR ?= $(INST_PREFIX)/lib64/lua/5.1
INST_LUADIR ?= $(INST_PREFIX)/share/lua/5.1
INST_BINDIR ?= /usr/bin
INSTALL ?= install
UNAME ?= $(shell uname)
OR_EXEC ?= $(shell which openresty)
LUAROCKS_VER ?= $(shell luarocks --version | grep -E -o  "luarocks [0-9]+.")


.PHONY: default
default:
ifeq ($(OR_EXEC), )
ifeq ("$(wildcard /usr/local/openresty-debug/bin/openresty)", "")
	@echo "ERROR: OpenResty not found. You have to install OpenResty and add the binary file to PATH before install Apache CEGOE."
	exit 1
endif
endif

LUAJIT_DIR ?= $(shell ${OR_EXEC} -V 2>&1 | grep prefix | grep -Eo 'prefix=(.*)/nginx\s+--' | grep -Eo '/.*/')luajit

### help:             Show Makefile rules.
.PHONY: help
help: default
	@echo Makefile rules:
	@echo
	@grep -E '^### [-A-Za-z0-9_]+:' Makefile | sed 's/###/   /'


### deps:             Installation dependencies
.PHONY: deps
deps: default
ifeq ($(LUAROCKS_VER),luarocks 3.)
	luarocks install --lua-dir=$(LUAJIT_DIR) rockspec/cegoe-master-0.rockspec --tree=deps --only-deps --local
else
	luarocks install rockspec/cegoe-master-0.rockspec --tree=deps --only-deps --local
endif


### utils:            Installation tools
.PHONY: utils
utils:
ifeq ("$(wildcard utils/lj-releng)", "")
	wget -O utils/lj-releng https://raw.githubusercontent.com/iresty/openresty-devel-utils/master/lj-releng
	chmod a+x utils/lj-releng
endif


### lint:             Lint Lua source code
.PHONY: lint
lint: utils
	./utils/check-lua-code-style.sh


### init:             Initialize the runtime environment
.PHONY: init
init: default
	./bin/cegoe init
	./bin/cegoe init_etcd


### run:              Start the cegoe server
.PHONY: run
run: default
	mkdir -p logs
	mkdir -p /tmp/cegoe_cores/
	$(OR_EXEC) -p $$PWD/ -c $$PWD/conf/nginx.conf


### stop:             Stop the cegoe server
.PHONY: stop
stop: default
	$(OR_EXEC) -p $$PWD/ -c $$PWD/conf/nginx.conf -s stop


### verify:           Verify the configuration of cegoe server
.PHONY: verify
verify: default
	$(OR_EXEC) -p $$PWD/ -c $$PWD/conf/nginx.conf -t


### clean:            Remove generated files
.PHONY: clean
clean:
	rm -rf logs/


### reload:           Reload the cegoe server
.PHONY: reload
reload: default
	$(OR_EXEC) -p $$PWD/  -c $$PWD/conf/nginx.conf -s reload


### install:          Install the cegoe
.PHONY: install
install:
	$(INSTALL) -d /usr/local/cegoe/logs/
	$(INSTALL) -d /usr/local/cegoe/conf/cert
	$(INSTALL) conf/mime.types /usr/local/cegoe/conf/mime.types
	$(INSTALL) conf/config.yaml /usr/local/cegoe/conf/config.yaml
	$(INSTALL) conf/cert/cegoe.* /usr/local/cegoe/conf/cert/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua
	$(INSTALL) lua/*.lua $(INST_LUADIR)/cegoe/lua/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe
	$(INSTALL) lua/cegoe/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/admin
	$(INSTALL) lua/cegoe/admin/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/admin/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/core
	$(INSTALL) lua/cegoe/core/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/core/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/http
	$(INSTALL) lua/cegoe/http/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/http/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/http/router
	$(INSTALL) lua/cegoe/http/router/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/http/router/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/plugins
	$(INSTALL) lua/cegoe/plugins/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/plugins/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/plugins/grpc-transcode
	$(INSTALL) lua/cegoe/plugins/grpc-transcode/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/plugins/grpc-transcode/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/plugins/limit-count
	$(INSTALL) lua/cegoe/plugins/limit-count/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/plugins/limit-count/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/plugins/prometheus
	$(INSTALL) lua/cegoe/plugins/prometheus/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/plugins/prometheus/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/plugins/zipkin
	$(INSTALL) lua/cegoe/plugins/zipkin/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/plugins/zipkin/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/stream/plugins
	$(INSTALL) lua/cegoe/stream/plugins/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/stream/plugins/

	$(INSTALL) -d $(INST_LUADIR)/cegoe/lua/cegoe/stream/router
	$(INSTALL) lua/cegoe/stream/router/*.lua $(INST_LUADIR)/cegoe/lua/cegoe/stream/router/

	$(INSTALL) README.md $(INST_CONFDIR)/README.md
	$(INSTALL) bin/cegoe $(INST_BINDIR)/cegoe


### test:             Run the test case
test:
	prove -I../test-nginx/lib -I./ -r -s t/

### license-check:    Check Lua source code for Apache License
# .PHONY: license-check
# license-check:
# ifeq ("$(wildcard .travis/openwhisk-utilities/scancode/scanCode.py)", "")
# 	git clone https://github.com/apache/openwhisk-utilities.git .travis/openwhisk-utilities
# 	cp .travis/ASF* .travis/openwhisk-utilities/scancode/
# endif
# 	.travis/openwhisk-utilities/scancode/scanCode.py --config .travis/ASF-Release.cfg ./


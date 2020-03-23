package = "cegoe"
version = "1.1-0"
supported_platforms = {"linux", "macosx"}

source = {
    url = "git://github.com/ciyoe/cegoe",
    branch = "master",
}

description = {
    summary = "ciyoe cegoe is a cloud-native microservices API gateway, delivering the ultimate performance, security, open source and scalable platform for all your APIs and microservices.",
    homepage = "https://github.com/ciyoe/cegoe",
    license = "Apache License 2.0",
}

dependencies = {
    "lua-resty-template = 1.9",
    "lua-resty-etcd = 0.8",
    "lua-resty-balancer = 0.02rc5",
    "lua-resty-ngxvar = 0.5",
    "lua-resty-jit-uuid = 0.0.7",
    "lua-resty-healthcheck-iresty = 2.0",
    "lua-resty-jwt = 0.2.0",
    "lua-resty-cookie = 0.1.0",
    "lua-resty-session = 2.24",
    "opentracing-openresty = 0.1",
    "lua-resty-radixtree = 1.7",
    "lua-protobuf = 0.3.1",
    "lua-resty-openidc = 1.7.2-1",
    "luafilesystem = 1.7.0-2",
    "lua-tinyyaml = 0.1",
    "lua-resty-prometheus = 1.0",
    "jsonschema = 0.5",
    "lua-resty-ipmatcher = 0.4",
}


build = {
    type = "make",
    build_variables = {
        CFLAGS="$(CFLAGS)",
        LIBFLAG="$(LIBFLAG)",
        LUA_LIBDIR="$(LUA_LIBDIR)",
        LUA_BINDIR="$(LUA_BINDIR)",
        LUA_INCDIR="$(LUA_INCDIR)",
        LUA="$(LUA)",
    },
    install_variables = {
        INST_PREFIX="$(PREFIX)",
        INST_BINDIR="$(BINDIR)",
        INST_LIBDIR="$(LIBDIR)",
        INST_LUADIR="$(LUADIR)",
        INST_CONFDIR="$(CONFDIR)",
    },
}

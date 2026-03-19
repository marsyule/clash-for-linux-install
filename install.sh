#!/usr/bin/env bash

. scripts/cmd/clashctl.sh
. scripts/preflight.sh

_valid
_parse_args "$@"

_prepare_zip
_detect_init

_okcat "安装内核：$KERNEL_NAME by ${INIT_TYPE}"
_okcat '📦' "安装路径：$CLASH_BASE_DIR"

/bin/cp -rf ./*  "$CLASH_BASE_DIR"

if command -v node >/dev/null 2>&1; then
    _okcat '📦' "安装Node.js依赖..."
    cd "$CLASH_BASE_DIR"
    if npm install --production 2>&1; then
        _okcat '✅' "Node.js依赖安装成功"
    else
        _failcat "npm install失败，JS脚本功能可能不可用"
    fi
    cd - >/dev/null
else
    _failcat "未检测到Node.js，JS脚本功能不可用"
fi

touch "$CLASH_CONFIG_BASE"
_set_envs
_is_regular_sudo && chown -R "$SUDO_USER" "$CLASH_BASE_DIR"

_install_service
_apply_rc


_merge_config
_detect_proxy_port
clashui
clashsecret "$(_get_random_val)" >/dev/null
clashsecret

_okcat '🎉' 'enjoy 🎉'
clashctl

_valid_config "$CLASH_CONFIG_BASE" && CLASH_CONFIG_URL="file://$CLASH_CONFIG_BASE"
_quit "clashsub add $CLASH_CONFIG_URL && clashsub use 1"

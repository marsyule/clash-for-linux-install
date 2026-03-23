#!/usr/bin/env bash

. scripts/cmd/clashctl.sh
. scripts/preflight.sh

_valid
_parse_args "$@"

_prepare_zip
_detect_init

_okcat "安装内核：$KERNEL_NAME by ${INIT_TYPE}"
_okcat '📦' "安装路径：$CLASH_BASE_DIR"

/bin/cp -rf . "$CLASH_BASE_DIR"

if command -v node >/dev/null 2>&1; then
    _okcat '📦' "安装 Node.js 依赖..."
    cd "$CLASH_BASE_DIR"
    # 临时禁用代理，安装完成后恢复
    if (
        # 使用数组保存和恢复代理环境变量
        proxy_vars=(http_proxy HTTP_PROXY https_proxy HTTPS_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY)
        # 保存当前代理设置
        for var in "${proxy_vars[@]}"; do
            eval "old_$var=\"\$$var\""
        done
        # 清除代理设置
        unset "${proxy_vars[@]}" 2>/dev/null
        export NO_PROXY='*' no_proxy='*'
        # 执行 npm install
        npm install --omit=dev --registry="https://registry.npmmirror.com" 2>&1
        exit_code=$?
        # 恢复原来的代理设置
        for var in "${proxy_vars[@]}"; do
            eval "[ -n \"\$old_$var\" ] && export $var=\"\$old_$var\""
        done
        
        exit $exit_code
    ); then
        _okcat '✅' "Node.js 依赖安装成功"
    else
        _failcat "npm install 失败，JS 脚本功能可能不可用"
    fi
    cd - >/dev/null
else
    _failcat "未检测到 Node.js，JS 脚本功能可能不可用"
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

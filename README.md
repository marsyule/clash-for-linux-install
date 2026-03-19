# Linux 一键安装 Clash (Develop Branch)

![GitHub License](https://img.shields.io/github/license/nelvko/clash-for-linux-install)
![GitHub top language](https://img.shields.io/github/languages/top/nelvko/clash-for-linux-install)
![GitHub Repo stars](https://img.shields.io/github/stars/nelvko/clash-for-linux-install)
![GitHub branch](https://img.shields.io/github/branch-name/marsyule/clash-for-linux-install/develop)

![preview](resources/preview.png)

> ⚠️ **注意**：这是 `develop` 开发分支，包含最新的实验性功能（如JS脚本系统）。如需稳定版本，请使用 [master 分支](https://github.com/marsyule/clash-for-linux-install/tree/master)。

## ✨ 功能特性

- 支持一键安装 `mihomo` 与 `clash` 代理内核。
- 兼容 `root` 与普通用户环境。
- 适配主流 `Linux` 发行版，并兼容 `AutoDL` 等容器化环境。
- 自动检测端口占用情况，在冲突时随机分配可用端口。
- 自动识别系统架构与初始化系统，下载匹配的内核与依赖，并生成对应的服务管理配置。
- 在需要时调用 [subconverter](https://github.com/tindy2013/subconverter) 进行本地订阅转换。
- **🆕 支持JS脚本系统**：通过编程方式修改订阅配置，实现复杂的配置逻辑。
- **🆕 三层配置架构**：订阅 → Mixin合并 → JS脚本处理 → 最终配置，高度解耦且易于扩展。
- **🆕 一对一脚本映射**：脚本ID与订阅ID一一对应，管理更清晰。

## 🚀 一键安装

在终端中执行以下命令即可完成安装：

```bash
git clone --branch develop --depth 1 https://gh-proxy.org/https://github.com/marsyule/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && bash install.sh
```

- 上述命令使用了[加速前缀](https://gh-proxy.org/)，如失效可更换其他[可用链接](https://ghproxy.link/)。
- **开发版本**：此为 `develop` 分支，包含最新的实验性功能。
- **稳定版本**：如需稳定版本，请将命令中的 `develop` 改为 `master`。
- 可通过 `.env` 文件或脚本参数自定义安装选项。
- 没有订阅？[click me](https://次元.net/auth/register?code=oUbI)

## ⌨️ 命令一览

```bash
Usage: 
  clashctl COMMAND [OPTIONS]

Commands:
    on                    开启代理
    off                   关闭代理
    status                内核状况
    proxy                 系统代理
    ui                    Web 面板
    secret                Web 密钥
    sub                   订阅管理
    script                脚本管理
    upgrade               升级内核
    tun                   Tun 模式
    mixin                 Mixin 配置

Global Options:
    -h, --help            显示帮助信息
```

💡`clashon` 同 `clashctl on`，`Tab` 补全更方便！

### 优雅启停

```bash
$ clashon
😼 已开启代理环境

$ clashoff
😼 已关闭代理环境
```
- 在启停代理内核的同时，同步设置系统代理。
- 亦可通过 `clashproxy` 单独控制系统代理。

### Web 控制台

```bash
$ clashui
╔═══════════════════════════════════════════════╗
║                😼 Web 控制台                  ║
║═══════════════════════════════════════════════║
║                                               ║
║     🔓 注意放行端口：9090                      ║
║     🏠 内网：http://192.168.0.1:9090/ui       ║
║     🌏 公网：http://8.8.8.8:9090/ui          ║
║     ☁️ 公共：http://board.zash.run.place      ║
║                                               ║
╚═══════════════════════════════════════════════╝

$ clashsecret mysecret
😼 密钥更新成功，已重启生效

$ clashsecret
😼 当前密钥：mysecret
```

- 可通过浏览器打开 `Web` 控制台进行可视化操作，例如切换节点、查看日志等。
- 默认使用 [zashboard](https://github.com/Zephyruso/zashboard) 作为控制台前端，如需更换可自行配置。
- 若需将控制台暴露到公网，建议定期更换访问密钥，或通过 `SSH` 端口转发方式进行安全访问。

### `Mixin` 配置

```bash
$ clashmixin
😼 查看 Mixin 配置

$ clashmixin -e
😼 编辑 Mixin 配置

$ clashmixin -c
😼 查看原始订阅配置

$ clashmixin -r
😼 查看运行时配置
```

- 通过 `Mixin` 自定义的配置内容会与原始订阅进行深度合并，且 `Mixin` 具有最高优先级，最终生成内核启动时加载的运行时配置。
- `Mixin` 支持以前置、后置或覆盖的方式，对原始订阅中的规则、节点及策略组进行新增或修改。

### 升级内核
```bash
$ clashupgrade
😼 请求内核升级...
{"status":"ok"}
😼 内核升级成功
```
- 升级过程由代理内核自动完成；如需查看详细的升级日志，可添加 `-v` 参数。
- 建议通过 `clashmixin` 为 `github` 配置代理规则，以避免因网络问题导致请求失败。

### 脚本管理

```bash
$ clashscript -h
clashscript - Clash 脚本管理工具

说明: 每个脚本对应一个订阅，脚本ID与订阅ID一一对应

Commands:
  add [id] <path>   添加脚本（可选指定ID，默认自动分配最小可用ID）
  ls                查看脚本列表
  del <id>          删除脚本
  enable <id>       启用脚本
  disable <id>      禁用脚本
```

#### 脚本功能说明

**脚本系统架构**：
```
原始订阅 (CLASH_CONFIG_BASE)
    ↓
Mixin合并 (CLASH_CONFIG_MIXIN)
    ↓
JS脚本处理 (execute_scripts)
    ↓
最终配置 (CLASH_CONFIG_RUNTIME)
```

**一对一对应关系**：
- 脚本ID = 订阅ID
- 每个订阅最多对应一个脚本
- 脚本独立控制，互不影响
- ID不能重复，自动按ID排序

**脚本作用**：
- 在订阅更新后自动执行
- 在mixin合并后的配置基础上进行进一步处理
- 支持编程式配置修改，实现复杂的配置逻辑

#### 示例脚本

**1. modify-subscription.js - 修改订阅信息**
```javascript
function main(config, profileName) {
    // 添加自定义规则
    if (!config.rules) config.rules = [];
    config.rules.unshift("DOMAIN-SUFFIX,example.com,proxy");
    
    // 创建智能代理组
    const nodes = config.proxies?.map(p => p.name) || [];
    config["proxy-groups"]?.push({
        name: "智能选择",
        type: "url-test",
        proxies: nodes
    });
    
    return config;
}
```

**2. filter-nodes.js - 过滤节点**
```javascript
function main(config, profileName) {
    // 过滤掉不需要的节点
    config.proxies = config.proxies?.filter(p => 
        !p.name.includes("过期") && 
        !p.name.includes("测试")
    ) || [];
    
    return config;
}
```

**3. auto-group.js - 自动分组**
```javascript
function main(config, profileName) {
    // 根据节点名称自动创建地区分组
    const singaporeNodes = config.proxies?.filter(p => 
        /新加坡|Singapore|SG/i.test(p.name)
    )?.map(p => p.name) || [];
    
    if (singaporeNodes.length > 0) {
        config["proxy-groups"]?.push({
            name: "新加坡节点",
            type: "url-test",
            proxies: singaporeNodes
        });
    }
    
    return config;
}
```

#### 使用示例

```bash
# 添加脚本（自动分配最小可用ID）
$ clashscript add examples/scripts/modify-subscription.js
🎉 已添加: [1] modify-subscription.js (对应订阅 1)

# 添加脚本（指定ID）
$ clashscript add 3 examples/scripts/filter-nodes.js
🎉 已添加: [3] filter-nodes.js (对应订阅 3)

# 查看脚本列表（按ID排序）
$ clashscript ls
[1] modify-subscription.js  [DISABLED]
[2] auto-group.js           [ENABLED]
[3] filter-nodes.js         [DISABLED]

# 启用脚本（对应订阅1）
$ clashscript enable 1
🎉 已启用脚本 [1] (对应订阅 1)

# 禁用脚本
$ clashscript disable 1
🎉 已禁用脚本 [1]

# 删除脚本
$ clashscript del 1
🎉 已删除: [1]

# ID自动填充示例
# 假设当前有脚本ID: 1, 3, 5
$ clashscript add test.js  # 自动分配ID=2（最小可用ID）
🎉 已添加: [2] test.js (对应订阅 2)
```

#### 工作流程

```bash
# 1. 添加订阅
$ clashsub add https://example.com/subscribe
✈️  订阅已添加: [1] https://example.com/subscribe

# 2. 添加对应脚本
$ clashscript add my-script.js
🎉 已添加: [1] my-script.js (对应订阅 1)

# 3. 启用脚本
$ clashscript enable 1
🎉 已启用脚本 [1] (对应订阅 1)

# 4. 使用订阅（自动执行脚本）
$ clashsub use 1
⏳ 执行脚本: 1_my-script.js
🔥 订阅已生效
```

#### 脚本接口规范

```javascript
/**
 * 脚本主函数
 * @param {Object} config - 合并后的配置对象（JSON格式）
 * @param {string} profileName - 订阅配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 修改config对象
    // ...
    
    // 返回修改后的配置
    return config;
}
```

#### 架构优势

1. **解耦性强**：订阅、Mixin、JS脚本三层分离，互不影响
2. **可扩展性**：每层都可以独立扩展和维护
3. **灵活性高**：支持声明式（Mixin）和编程式（JS脚本）两种配置方式
4. **向后兼容**：不影响现有的Mixin机制，JS脚本是可选增强功能
5. **一对一对应**：脚本ID与订阅ID一一对应，管理更清晰

### 管理订阅

```bash
$ clashsub -h
Usage: 
  clashsub COMMAND [OPTIONS]

Commands:
  add <url>       添加订阅
  ls              查看订阅
  del <id>        删除订阅
  use <id>        使用订阅
  update [id]     更新订阅
  log             订阅日志


Options:
  update:
    --auto        配置自动更新
    --convert     使用订阅转换
```

- 支持添加本地订阅，例如：`file:///root/clashctl/resources/config.yaml`
- 当订阅链接解析失败或包含特殊字符时，请使用引号包裹以避免被错误解析。
- 自动更新任务可通过 `crontab -e` 进行修改和管理。

### `Tun` 模式

```bash
$ clashtun
😾 Tun 状态：关闭

$ clashtun on
😼 Tun 模式已开启
```

- 作用：实现本机及 `Docker` 等容器的所有流量路由到 `clash` 代理、DNS 劫持等。
- 原理：[clash-verge-rev](https://www.clashverge.dev/guide/term.html#tun)、 [clash.wiki](https://clash.wiki/premium/tun-device.html)。
- 注意事项：[#100](https://github.com/nelvko/clash-for-linux-install/issues/100#issuecomment-2782680205)

## 🗑️ 卸载

```bash
bash uninstall.sh
```

## 📖 常见问题

👉 [Wiki · FAQ](https://github.com/nelvko/clash-for-linux-install/wiki/FAQ)

## 🔗 引用

- [clash](https://clash.wiki/)
- [mihomo](https://github.com/MetaCubeX/mihomo)
- [subconverter](https://github.com/tindy2013/subconverter)
- [yq](https://github.com/mikefarah/yq)
- [zashboard](https://github.com/Zephyruso/zashboard)

## ⭐ Star History

<a href="https://www.star-history.com/#nelvko/clash-for-linux-install&Date">

 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=nelvko/clash-for-linux-install&type=Date" />
 </picture>
</a>

## 🙏 Thanks

[@鑫哥](https://github.com/TrackRay)

## ⚠️ 特别声明

1. 编写本项目主要目的为学习和研究 `Shell` 编程，不得将本项目中任何内容用于违反国家/地区/组织等的法律法规或相关规定的其他用途。
2. 本项目保留随时对免责声明进行补充或更改的权利，直接或间接使用本项目内容的个人或组织，视为接受本项目的特别声明。

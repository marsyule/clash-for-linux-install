/**
 * 示例脚本：添加自定义规则
 * 
 * @param {Object} config - Clash配置对象
 * @param {string} profileName - 配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 确保rules数组存在
    if (!config.rules) {
        config.rules = [];
    }
    
    // 添加自定义规则到开头
    const customRules = [
        // 将百度分流到直连
        "DOMAIN-SUFFIX,baidu.com,DIRECT",
        // 将GitHub分流到代理（如果代理组中有"proxy"）
        "DOMAIN-SUFFIX,github.com,proxy",
        // 将本地地址直连
        "DOMAIN-SUFFIX,localhost,DIRECT",
        "DOMAIN-SUFFIX,local,DIRECT",
        "IP-CIDR,127.0.0.0/8,DIRECT",
        "IP-CIDR,192.168.0.0/16,DIRECT",
        "IP-CIDR,10.0.0.0/8,DIRECT"
    ];
    
    // 将自定义规则添加到现有规则前面
    config.rules = customRules.concat(config.rules);
    
    console.log(`已为配置 "${profileName}" 添加 ${customRules.length} 条自定义规则`);
    
    return config;
}

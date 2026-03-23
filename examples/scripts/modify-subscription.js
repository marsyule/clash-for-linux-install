/**
 * 示例脚本：修改订阅信息
 * 
 * @param {Object} config - 合并后的配置对象
 * @param {string} profileName - 订阅配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 添加自定义规则到开头
    if (!config.rules) config.rules = [];
    config.rules.unshift("DOMAIN-SUFFIX,example.com,proxy");
    
    // 创建智能代理组
    const nodes = config.proxies?.map(p => p.name) || [];
    if (nodes.length > 0) {
        if (!config["proxy-groups"]) config["proxy-groups"] = [];
        
        config["proxy-groups"].push({
            name: "智能选择",
            type: "url-test",
            proxies: nodes,
            url: "https://www.gstatic.com/generate_204",
            interval: 300
        });
    }
    
    console.log(`✅ 已为配置 "${profileName}" 添加自定义规则和智能代理组`);
    
    return config;
}

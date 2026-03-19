/**
 * 示例脚本：过滤节点
 * 
 * @param {Object} config - 合并后的配置对象
 * @param {string} profileName - 订阅配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 过滤掉不需要的节点
    if (!config.proxies) config.proxies = [];
    
    const originalCount = config.proxies.length;
    
    config.proxies = config.proxies.filter(p => 
        !p.name.includes("过期") && 
        !p.name.includes("测试") &&
        !p.name.includes("到期") &&
        !p.name.includes("过期时间")
    );
    
    const filteredCount = originalCount - config.proxies.length;
    
    console.log(`✅ 已为配置 "${profileName}" 过滤掉 ${filteredCount} 个节点`);
    
    return config;
}

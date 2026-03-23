/**
 * 示例脚本：修改代理组配置
 * 
 * @param {Object} config - Clash配置对象
 * @param {string} profileName - 配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 确保proxy-groups数组存在
    if (!config['proxy-groups']) {
        config['proxy-groups'] = [];
    }
    
    // 查找或创建"自动选择"代理组
    let autoSelectGroup = config['proxy-groups'].find(g => g.name === '自动选择');
    
    if (!autoSelectGroup) {
        // 创建新的自动选择代理组
        autoSelectGroup = {
            name: '自动选择',
            type: 'url-test',
            proxies: [],
            url: 'http://www.gstatic.com/generate_204',
            interval: 300
        };
        config['proxy-groups'].push(autoSelectGroup);
    }
    
    // 确保proxies数组存在
    if (!config.proxies) {
        config.proxies = [];
    }
    
    // 将所有代理添加到自动选择组
    const proxyNames = config.proxies.map(p => p.name);
    autoSelectGroup.proxies = [...new Set([...autoSelectGroup.proxies, ...proxyNames])];
    
    // 创建或更新"手动选择"代理组
    let manualSelectGroup = config['proxy-groups'].find(g => g.name === '手动选择');
    
    if (!manualSelectGroup) {
        manualSelectGroup = {
            name: '手动选择',
            type: 'select',
            proxies: ['自动选择', ...proxyNames]
        };
        config['proxy-groups'].push(manualSelectGroup);
    } else {
        // 更新手动选择组，确保包含所有代理
        manualSelectGroup.proxies = ['自动选择', ...proxyNames];
    }
    
    // 创建或更新"国外流量"代理组
    let foreignGroup = config['proxy-groups'].find(g => g.name === '国外流量');
    
    if (!foreignGroup) {
        foreignGroup = {
            name: '国外流量',
            type: 'select',
            proxies: ['自动选择', '手动选择', 'DIRECT']
        };
        config['proxy-groups'].push(foreignGroup);
    }
    
    // 创建或更新"国内流量"代理组
    let domesticGroup = config['proxy-groups'].find(g => g.name === '国内流量');
    
    if (!domesticGroup) {
        domesticGroup = {
            name: '国内流量',
            type: 'select',
            proxies: ['DIRECT', '手动选择', '自动选择']
        };
        config['proxy-groups'].push(domesticGroup);
    }
    
    console.log(`已为配置 "${profileName}" 更新代理组配置`);
    console.log(`- 自动选择组包含 ${autoSelectGroup.proxies.length} 个代理`);
    console.log(`- 手动选择组包含 ${manualSelectGroup.proxies.length} 个选项`);
    
    return config;
}

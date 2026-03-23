/**
 * 示例脚本：根据配置文件名称执行不同操作
 * 
 * @param {Object} config - Clash配置对象
 * @param {string} profileName - 配置文件名称
 * @returns {Object} 修改后的配置对象
 */
function main(config, profileName) {
    // 根据配置文件名称执行不同的操作
    if (profileName === "1") {
        // 配置文件1：添加游戏加速规则
        const gameRules = [
            "DOMAIN-SUFFIX,steam.com,proxy",
            "DOMAIN-SUFFIX,steampowered.com,proxy",
            "DOMAIN-SUFFIX,epicgames.com,proxy",
            "DOMAIN-SUFFIX,ea.com,proxy",
            "DOMAIN-SUFFIX,ubisoft.com,proxy"
        ];
        
        if (!config.rules) {
            config.rules = [];
        }
        
        config.rules = gameRules.concat(config.rules);
        console.log(`为配置 "${profileName}" 添加了游戏加速规则`);
        
    } else if (profileName === "2") {
        // 配置文件2：添加流媒体规则
        const mediaRules = [
            "DOMAIN-SUFFIX,netflix.com,proxy",
            "DOMAIN-SUFFIX,youtube.com,proxy",
            "DOMAIN-SUFFIX,disney.com,proxy",
            "DOMAIN-SUFFIX,hulu.com,proxy",
            "DOMAIN-SUFFIX,bilibili.com,DIRECT"
        ];
        
        if (!config.rules) {
            config.rules = [];
        }
        
        config.rules = mediaRules.concat(config.rules);
        console.log(`为配置 "${profileName}" 添加了流媒体规则`);
        
    } else {
        // 其他配置文件：添加通用规则
        const commonRules = [
            "DOMAIN-SUFFIX,google.com,proxy",
            "DOMAIN-SUFFIX,facebook.com,proxy",
            "DOMAIN-SUFFIX,twitter.com,proxy",
            "DOMAIN-SUFFIX,github.com,proxy",
            "DOMAIN-SUFFIX,baidu.com,DIRECT",
            "DOMAIN-SUFFIX,qq.com,DIRECT",
            "DOMAIN-SUFFIX,taobao.com,DIRECT"
        ];
        
        if (!config.rules) {
            config.rules = [];
        }
        
        config.rules = commonRules.concat(config.rules);
        console.log(`为配置 "${profileName}" 添加了通用规则`);
    }
    
    // 确保DNS配置存在
    if (!config.dns) {
        config.dns = {
            enable: true,
            listen: "0.0.0.0:1053",
            "enhanced-mode": "fake-ip",
            nameserver: ["114.114.114.114", "8.8.8.8"]
        };
    }
    
    return config;
}

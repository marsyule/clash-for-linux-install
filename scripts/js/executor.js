#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

function main() {
    const args = process.argv.slice(2);
    
    if (args.length < 2) {
        console.error('Usage: node executor.js <config_file> <script_file> [profile_name]');
        process.exit(1);
    }
    
    const configFile = args[0];
    const scriptFile = args[1];
    const profileName = args[2] || 'default';
    
    try {
        const configContent = fs.readFileSync(configFile, 'utf8');
        const config = yaml.load(configContent);
        
        const scriptContent = fs.readFileSync(scriptFile, 'utf8');
        
        const scriptFunction = new Function('config', 'profileName', scriptContent + '\nreturn main(config, profileName);');
        
        const modifiedConfig = scriptFunction(config, profileName);
        
        if (!modifiedConfig) {
            console.error('Error: Script must return a config object');
            process.exit(1);
        }
        
        const modifiedYaml = yaml.dump(modifiedConfig, {
            indent: 2,
            lineWidth: -1,
            noRefs: true,
            sortKeys: false
        });
        
        fs.writeFileSync(configFile, modifiedYaml, 'utf8');
        
        console.log(`✅ Script executed successfully: ${path.basename(scriptFile)}`);
        
    } catch (error) {
        console.error(`❌ Error executing script: ${error.message}`);
        process.exit(1);
    }
}

main();

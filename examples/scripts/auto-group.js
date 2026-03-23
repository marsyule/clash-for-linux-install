function prioritizeGroup(config, group, targetGroupName = "节点选择") {
  if (!group) return config;

  if (!Array.isArray(config["proxy-groups"])) {
    config["proxy-groups"] = [];
  }

  const existingIndex = config["proxy-groups"].findIndex(g => g.name === group.name);
  if (existingIndex !== -1) {
    config["proxy-groups"].splice(existingIndex, 1);
  }

  config["proxy-groups"].unshift(group);

  const selectGroup = config["proxy-groups"].find(g => g.name === targetGroupName);
  if (selectGroup) {
    if (!Array.isArray(selectGroup.proxies)) {
      selectGroup.proxies = [];
    }
    selectGroup.proxies = selectGroup.proxies.filter(p => p !== group.name);
    selectGroup.proxies.unshift(group.name);
  }

  return config;
}

function createAndPrioritizeGroup(config, groupName, nameRegex) {
  const nodes = config.proxies
    ?.filter(p => nameRegex.test(p.name))
    ?.map(p => p.name) || [];

  if (nodes.length === 0) {
    return config;
  }

  const group = {
    name: groupName,
    type: "url-test",
    proxies: nodes,
    url: "https://www.gstatic.com/generate_204",
    interval: 600,
    tolerance: 200
  };

  return prioritizeGroup(config, group);
}

function createAndPrioritizeMetaGroup(config, groupName, memberGroups) {
  if (!Array.isArray(memberGroups) || memberGroups.length === 0) {
    return config;
  }

  const existingGroupNames = new Set(
    (config["proxy-groups"] || []).map(g => g.name)
  );

  const proxies = memberGroups.filter(name => existingGroupNames.has(name));
  if (proxies.length === 0) {
    return config;
  }

  const group = {
    name: groupName,
    type: "select",
    proxies
  };

  return prioritizeGroup(config, group);
}

function main(config) {
  config = createAndPrioritizeGroup(
    config,
    "新加坡自动节点",
    /新加坡|Singapore|SG/i
  );

  config = createAndPrioritizeGroup(
    config,
    "日本自动节点",
    /日本|Japan|JP|东京|大阪|横滨|福冈|札幌|京都/i
  );

  config = createAndPrioritizeGroup(
    config,
    "香港自动节点",
    /香港|HK|Hk/i
  );

  config = createAndPrioritizeMetaGroup(
    config,
    "地区限定的自动节点选择",
    ["新加坡自动节点", "日本自动节点", "香港自动节点"]
  );

  return config;
}

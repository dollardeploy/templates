import yaml from "js-yaml";

const logger = console;

export const fetchDirectory = async path => {
  logger.warn("Fetching directory", path);
  const result = await fetch(
    `https://api.github.com/repos/dollardeploy/templates/contents/${path ?? ""}`,
    {
      headers: process.env.GITHUB_TOKEN
        ? {
            Authorization: process.env.GITHUB_TOKEN
          }
        : undefined
    }
  ).then(r => r.json());
  return result;
};

export const fetchGitHubFile = async path => {
  logger.warn("Fetching file", path);
  return fetch(`https://raw.githubusercontent.com/dollardeploy/templates/main/${path}`, {
    headers: process.env.GITHUB_TOKEN
      ? {
          Authorization: process.env.GITHUB_TOKEN
        }
      : undefined
  }).then(r => r.text());
};

export const getGithubTemplate = async (id, optional) => {
  logger.warn("Fetching template", id);
  const json = await fetchDirectory(id);

  const config = json.find(
    f =>
      f.type === "file" &&
      [".dollardeploy.yml", ".dollardeploy.yaml", ".dollardeploy.json"].includes(f.name)
  );

  if (!config && optional) {
    return null;
  }

  if (!config) {
    throw new Error("No dollardeploy config found for template " + id);
  }

  logger.warn("Found dollardeploy config for template", id, config.path);
  return fetchGitHubFile(config.path).then(c => {
    if (config.name.endsWith(".json")) {
      return JSON.parse(c);
    }

    if (config.name.endsWith(".yaml") || config.name.endsWith(".yml")) {
      return yaml.load(c);
    }

    throw new Error("Unknown dollardeploy config file type for template " + id);
  });
};

const getTemplates = async () => {
  const json = await fetchDirectory();
  logger.warn("Found templates", json);
  const ids = json.filter(f => f.type === "dir").map(f => f.name);
  const configs = [];
  configs.push(
    ...(await Promise.all(ids.map(id => getGithubTemplate(id, true)))).filter(v => !!v)
  );
  return configs;
};

const main = async () => {
  const templates = await getTemplates();
  process.stdout.write(JSON.stringify(templates, null, 2));
};

main();

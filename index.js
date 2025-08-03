import yaml from "js-yaml";
import paths from "node:path";

const logger = console;

export const fetchDirectory = async path => {
  logger.warn("Fetching directory", path);
  const response = await fetch(
    `https://api.github.com/repos/dollardeploy/templates/contents/${path ?? ""}`,
    {
      headers: process.env.GITHUB_TOKEN
        ? {
            Authorization: process.env.GITHUB_TOKEN
          }
        : undefined
    }
  );
  if (!response.ok) {
    throw new Error("Failed to fetch directory " + path + ": " + response.status);
  }
  return response.json();
};

export const fetchGitHubFile = async path => {
  logger.warn("Fetching file", path);
  const response = await fetch(`https://raw.githubusercontent.com/dollardeploy/templates/main/${path}`, {
    headers: process.env.GITHUB_TOKEN
      ? {
          Authorization: process.env.GITHUB_TOKEN
        }
      : undefined
  });
  if (!response.ok) {
    throw new Error("Failed to fetch file " + path + ": " + response.status);
  }
  return response.text();
};

export const getGithubTemplate = async (id, optional) => {
  logger.warn("Fetching template", id);
  const json = await fetchDirectory(id);

  if (!Array.isArray(json)) {
    throw new Error("Invalid response from GitHub API for template " + id + ": " + JSON.stringify(json));
  }

  const config = json.find(
    f =>
      f.type === "file" &&
      [".dollardeploy.yml", ".dollardeploy.yaml", ".dollardeploy.json"].includes(f.name)
  );

  if (!config && optional) {
    return null;
  }

  if (!config) {
    throw new Error("No DollarDeploy config found for template " + id);
  }

  logger.warn("Found DollarDeploy config for template", id, config.path);
  const template = await fetchGitHubFile(config.path).then(c => {
    if (config.name.endsWith(".json")) {
      return JSON.parse(c);
    }

    if (config.name.endsWith(".yaml") || config.name.endsWith(".yml")) {
      return yaml.load(c);
    }

    throw new Error("Unknown dollardeploy config file type for template " + id);
  });

  if (Array.isArray(template.app?.files)) {
    template.app.files = await Promise.all(
      template.app.files.map(f => {
        if (f.path && !f.content) {
          const path = paths.resolve(paths.dirname(config.path), f.path);
          logger.warn("Fetching file", path);
          return fetchGitHubFile(path).then(content => ({ ...f, content }));
        }
        return f;
      })
    );
  }

  return template;
};

const getTemplates = async () => {
  const json = await fetchDirectory();
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

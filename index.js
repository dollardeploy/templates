import yaml from "js-yaml";
import fs from "node:fs";
import path from "node:path";

const logger = console;

const DOLLARDEPLOY_CONFIG_FILES = [".dollardeploy.yml", ".dollardeploy.yaml", ".dollardeploy.json"];

/**
 * Get all template directories from the local filesystem
 */
const getTemplateDirectories = (basePath) => {
  const entries = fs.readdirSync(basePath, { withFileTypes: true });
  return entries
    .filter(entry => entry.isDirectory() && !entry.name.startsWith(".") && entry.name !== "node_modules")
    .map(entry => entry.name);
};

/**
 * Find the DollarDeploy config file in a directory
 */
const findConfigFile = (templatePath) => {
  for (const configName of DOLLARDEPLOY_CONFIG_FILES) {
    const configPath = path.join(templatePath, configName);
    if (fs.existsSync(configPath)) {
      return { name: configName, path: configPath };
    }
  }
  return null;
};

/**
 * Parse a config file (YAML or JSON)
 */
const parseConfigFile = (configFile) => {
  const content = fs.readFileSync(configFile.path, "utf-8");

  if (configFile.name.endsWith(".json")) {
    return JSON.parse(content);
  }

  if (configFile.name.endsWith(".yaml") || configFile.name.endsWith(".yml")) {
    return yaml.load(content);
  }

  throw new Error(`Unknown config file type: ${configFile.name}`);
};

/**
 * Resolve file references in the template config
 */
const resolveFileReferences = (template, templateDir) => {
  if (!Array.isArray(template.app?.files)) {
    return template;
  }

  template.app.files = template.app.files.map(file => {
    if (file.path && !file.content) {
      const filePath = path.resolve(templateDir, file.path);
      logger.warn("Reading file", filePath);

      if (!fs.existsSync(filePath)) {
        throw new Error(`Referenced file not found: ${filePath}`);
      }

      const content = fs.readFileSync(filePath, "utf-8");
      return { ...file, content };
    }
    return file;
  });

  return template;
};

/**
 * Get a single template from the local filesystem
 */
const getLocalTemplate = (basePath, templateId, optional = false) => {
  logger.warn("Processing template", templateId);
  const templatePath = path.join(basePath, templateId);

  const configFile = findConfigFile(templatePath);

  if (!configFile && optional) {
    return null;
  }

  if (!configFile) {
    throw new Error(`No DollarDeploy config found for template ${templateId}`);
  }

  logger.warn("Found config", configFile.path);

  let template = parseConfigFile(configFile);
  template = resolveFileReferences(template, templatePath);

  return template;
};

/**
 * Get all templates from the local filesystem
 */
const getTemplates = (basePath) => {
  const templateIds = getTemplateDirectories(basePath);
  logger.warn("Found template directories:", templateIds.join(", "));

  const templates = [];

  for (const id of templateIds) {
    const template = getLocalTemplate(basePath, id, true);
    if (template) {
      templates.push(template);
    }
  }

  return templates;
};

const main = () => {
  const basePath = process.cwd();
  const templates = getTemplates(basePath);
  process.stdout.write(JSON.stringify(templates, null, 2));
};

main();

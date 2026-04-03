import yaml from "js-yaml";
import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";

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
 * Get git timestamps for a template directory
 */
const getGitTimestamps = (basePath, templateId) => {
  const relativePath = templateId;
  try {
    const updatedAt = execSync(
      `git log -1 --format=%aI -- "${relativePath}"`,
      { cwd: basePath, encoding: "utf-8" }
    ).trim();
    const createdAt = execSync(
      `git log --follow --format=%aI -- "${relativePath}" | tail -1`,
      { cwd: basePath, encoding: "utf-8", shell: true }
    ).trim();
    return {
      createdAt: createdAt || null,
      updatedAt: updatedAt || null,
    };
  } catch {
    return { createdAt: null, updatedAt: null };
  }
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

  const { createdAt, updatedAt } = getGitTimestamps(basePath, templateId);
  template.createdAt = createdAt;
  template.updatedAt = updatedAt;

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

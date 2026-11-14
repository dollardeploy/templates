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

const LOGO_EXTENSIONS = [".svg", ".png", ".jpg", ".jpeg", ".webp", ".gif"];
const LOGO_MAX_BYTES = 256 * 1024;
const LOGO_CDN = "https://cdn.jsdelivr.net/gh/dollardeploy/templates";

/**
 * Resolve the template logo. Logos are stored next to the template config, never hotlinked:
 * upstream sites move or delete their images and the catalog card breaks. The local file is
 * served from jsDelivr (correct image MIME type, unlike raw.githubusercontent.com for SVG),
 * pinned to the commit that last changed it so a replaced logo is never served stale.
 */
const resolveLogo = (basePath, templateId, logo) => {
  if (!logo) {
    return logo;
  }

  if (/^[a-z]+:/i.test(logo)) {
    throw new Error(
      `Template ${templateId}: logo must be a file in the template directory (e.g. logo: logo.svg), not a URL: ${logo}`
    );
  }

  const templatePath = path.join(basePath, templateId);
  const logoPath = path.resolve(templatePath, logo);
  if (!logoPath.startsWith(templatePath + path.sep)) {
    throw new Error(`Template ${templateId}: logo must stay inside the template directory: ${logo}`);
  }

  if (!LOGO_EXTENSIONS.includes(path.extname(logoPath).toLowerCase())) {
    throw new Error(`Template ${templateId}: logo must be one of ${LOGO_EXTENSIONS.join(", ")}: ${logo}`);
  }

  if (!fs.existsSync(logoPath)) {
    throw new Error(`Template ${templateId}: logo file not found: ${logo}`);
  }

  const size = fs.statSync(logoPath).size;
  if (size === 0 || size > LOGO_MAX_BYTES) {
    throw new Error(`Template ${templateId}: logo must be 1 byte to ${LOGO_MAX_BYTES} bytes, got ${size}: ${logo}`);
  }

  const relativePath = path.relative(basePath, logoPath).split(path.sep).join("/");
  let ref = "main";
  try {
    ref =
      execSync(`git log -1 --format=%H -- "${relativePath}"`, { cwd: basePath, encoding: "utf-8" }).trim() || "main";
  } catch {
    // Not committed yet (local run): fall back to the branch
  }

  return `${LOGO_CDN}@${ref}/${relativePath}`;
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
  template.logo = resolveLogo(basePath, templateId, template.logo);

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

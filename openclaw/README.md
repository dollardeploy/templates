# OpenClaw - Self-Hosted AI Assistant

OpenClaw is a self-hosted AI assistant platform that integrates with multiple messaging platforms including WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, and more.

## Features

- **Multi-channel messaging integration** - Connect with WhatsApp, Telegram, Slack, Discord, and more
- **Native browser control** - VNC server enables advanced browser automation
- **Voice interaction** - Communicate with AI using voice commands
- **Extensible tools** - Browser control, file operations, cron scheduling
- **Security-first design** - Pairing-based access control
- **Canvas visualization** - Rich visual outputs and skills registry

## Documentation

For more information, visit:
- Official Documentation: https://docs.openclaw.ai/
- GitHub Repository: https://github.com/openclaw/openclaw
- Website: https://openclaw.io/
- Docker Image: https://hub.docker.com/r/fourplayers/openclaw

## Server Requirements

For optimal performance with native browser control:

- **CPU**: 4 vCPU
- **RAM**: 8GB
- **Storage**: 60GB
- **OS**: Ubuntu 20.04+ or Debian-based system

## Quick Installation

### Automated Deployment (Recommended)

When deploying via DollarDeploy or similar platforms:

1. **Pre-start**: `deploy.sh` runs automatically to install all dependencies
2. **Start**: `server.js` launches a status page showing installation progress
3. **Monitor**: Visit the deployment URL to track installation in real-time

The status page provides:
- Live installation progress (0-100%)
- Component status (OpenClaw, VNC server)
- Quick start commands
- Direct links to documentation

### Manual Installation

For manual installation on your own server:

```bash
# Clone the templates repository
git clone https://github.com/dollardeploy/templates.git
cd templates/openclaw

# Run the deployment script
./deploy.sh

# Optional: Start the status server
./server.js
```

The `deploy.sh` script will:
- ✅ Install pnpm package manager
- ✅ Install nvm and Node.js 22
- ✅ Configure systemd user daemon
- ✅ Install and configure VNC server
- ✅ Set VNC password from `VNC_PASSWORD` environment variable
- ✅ Configure VNC xstartup with XFCE4 and clipboard sync
- ✅ Install OpenClaw globally
- ✅ Set up browser extension
- ✅ Enable auto-start services
- ✅ Check for previously completed steps (idempotent)

## Status Server

The included `server.js` provides a beautiful web interface for monitoring your OpenClaw installation:

### Features
- **Real-time Progress** - Live updates during installation (auto-refresh every 10s)
- **System Status** - OpenClaw and VNC server status badges
- **Quick Links** - Direct access to documentation, GitHub, and website
- **Responsive Design** - Works on desktop and mobile
- **Health Check API** - `/health` endpoint for monitoring

### Endpoints
- `http://localhost:18789/` - Main status page
- `http://localhost:18789/health` - JSON health check

The status page automatically refreshes during installation and provides visual feedback on:
- Installation progress percentage
- Completed vs total steps
- OpenClaw installation status
- VNC server running status
- Quick start commands and links

## What Gets Installed

### Core Dependencies
- **pnpm** - Fast, disk space efficient package manager
- **nvm** - Node Version Manager
- **Node.js 22** - JavaScript runtime

### System Services
- **VNC Server** (tightvncserver) - For browser control
  - Display: `:1` (port `5901`)
  - Resolution: `1920x1080`
  - Depth: `24-bit`
  - Password: Auto-configured from `VNC_PASSWORD` env variable (or prompted on first connection)
  - Desktop: XFCE4 with clipboard sync (autocutsel)
- **systemd** - Auto-start configuration

### OpenClaw Components
- **Global CLI** - `openclaw` command available system-wide
- **Browser Extension** - Symlinked to `~/openclaw-extension`
- **Configuration** - Stored in `~/.openclaw/`

## Post-Installation

After running `deploy.sh`, follow these steps:

1. **Reload your shell environment:**
   ```bash
   source ~/.bashrc
   ```

2. **Start OpenClaw:**
   ```bash
   openclaw
   ```

3. **Set VNC password** (if not set during deployment):
   ```bash
   # Option 1: Set password using environment variable (recommended for automation)
   export VNC_PASSWORD="your-secure-password"
   echo "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd
   chmod 600 ~/.vnc/passwd

   # Option 2: Interactive password setup
   vncpasswd
   ```

4. **Access VNC server** (for browser control):
   - Connect to `localhost:5901`
   - Use any VNC client (TigerVNC, RealVNC, etc.)
   - If password wasn't set via `VNC_PASSWORD`, you'll be prompted to set it on first connection

5. **Install browser extension:**
   - Load unpacked extension from `~/openclaw-extension`
   - In Chrome/Brave: `chrome://extensions/` → Enable Developer Mode → Load Unpacked
   - Select the `~/openclaw-extension` directory

6. **Configure AI providers:**
   - Set your API keys as environment variables or in OpenClaw config
   - `ANTHROPIC_API_KEY` - For Claude AI
   - `OPENAI_API_KEY` - For OpenAI models
   - `OPENROUTER_API_KEY` - For OpenRouter

## Manual Installation

If you prefer to install manually, see the detailed steps in the `deploy.sh` script.

## Troubleshooting

### OpenClaw command not found
- Run: `source ~/.bashrc`
- Check PATH: `echo $PATH | grep pnpm`

### VNC server not starting
- Check status: `sudo systemctl status vncserver@1`
- View logs: `journalctl -u vncserver@1 -n 50`
- Restart: `sudo systemctl restart vncserver@1`

### Node.js version issues
- Load nvm: `source ~/.nvm/nvm.sh`
- Check version: `node --version` (should be v22.x.x)
- Switch version: `nvm use 22`

## Uninstallation

To remove OpenClaw and its components:

```bash
# Stop VNC service
sudo systemctl stop vncserver@1
sudo systemctl disable vncserver@1

# Remove OpenClaw
pnpm remove -g openclaw

# Remove installation tracking
rm -rf ~/.openclaw-install

# Optionally remove VNC server
sudo apt remove tightvncserver autocutsel dbus-x11
```

## Support

- Issues: https://github.com/openclaw/openclaw/issues
- Documentation: https://docs.openclaw.ai/
- Community: Check the GitHub repository for community links


## Environment Variables

The following environment variables can be used during installation:

- `VNC_PASSWORD` - Automatically set VNC server password (recommended for automated deployments)
- `ANTHROPIC_API_KEY` - API key for Claude AI
- `OPENAI_API_KEY` - API key for OpenAI models
- `OPENROUTER_API_KEY` - API key for OpenRouter

Example:
```bash
export VNC_PASSWORD="my-secure-vnc-password"
./deploy.sh
```

## Advanced Configuration

### VNC Server Configuration

The VNC server is configured with the following xstartup script (`~/.vnc/xstartup`):

```bash
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
# Allow sudo in VNC viewer:
xhost +localhost
xrdb $HOME/.Xresources
autocutsel -fork
sleep 2
startxfce4 &
```

This configuration:
- Disables X keyboard layout issues
- Enables sudo commands in VNC session
- Loads X resources
- Enables clipboard synchronization (autocutsel)
- Starts XFCE4 desktop environment

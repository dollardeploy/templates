#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${GREEN}==>${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a step was already completed
step_completed() {
    local step_file="$HOME/.openclaw-install/$1"
    [ -f "$step_file" ]
}

# Mark step as completed
mark_step_completed() {
    local step_file="$HOME/.openclaw-install/$1"
    mkdir -p "$HOME/.openclaw-install"
    touch "$step_file"
    log_info "Step marked as completed: $1"
}

# Main installation
main() {
    log_step "Starting OpenClaw Native Installation"

    # Create installation tracking directory
    mkdir -p "$HOME/.openclaw-install"

    # Step 1: Install pnpm
    if step_completed "pnpm_installed"; then
        log_info "pnpm already installed, skipping..."
    else
        log_step "Installing pnpm"
        if command_exists pnpm; then
            log_info "pnpm already exists in PATH"
        else
            curl -fsSL https://get.pnpm.io/install.sh | sh -
            export PATH="$HOME/.local/share/pnpm:$PATH"

            # Add pnpm to PATH in profile files if not already present
            for profile in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
                if [ -f "$profile" ] && ! grep -q "pnpm" "$profile"; then
                    echo 'export PATH="$HOME/.local/share/pnpm:$PATH"' >> "$profile"
                fi
            done
        fi
        mark_step_completed "pnpm_installed"
    fi

    # Step 2: Install nvm
    if step_completed "nvm_installed"; then
        log_info "nvm already installed, skipping..."
    else
        log_step "Installing nvm"
        if [ -d "$HOME/.nvm" ]; then
            log_info "nvm directory already exists"
        else
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
        fi

        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        mark_step_completed "nvm_installed"
    fi

    # Step 3: Install Node.js 22
    if step_completed "node22_installed"; then
        log_info "Node.js 22 already installed, skipping..."
    else
        log_step "Installing Node.js 22"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        nvm install 22
        nvm use 22
        nvm alias default 22

        log_info "Node version: $(node --version)"
        log_info "npm version: $(npm --version)"

        mark_step_completed "node22_installed"
    fi

    # Step 4: Setup systemd user daemon environment
    if step_completed "systemd_env_configured"; then
        log_info "systemd environment already configured, skipping..."
    else
        log_step "Configuring systemd user daemon environment"

        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

        # Add to bashrc if not already present
        if ! grep -q "XDG_RUNTIME_DIR" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" <<'EOF'
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
EOF
            log_info "Added systemd environment variables to .bashrc"
        fi

        mark_step_completed "systemd_env_configured"
    fi

    # Step 5: Enable systemd linger
    if step_completed "systemd_linger_enabled"; then
        log_info "systemd linger already enabled, skipping..."
    else
        log_step "Enabling systemd linger for current user"

        # Enable linger for current user (allows user services to run without login)
        if command_exists loginctl; then
            sudo loginctl enable-linger "$(whoami)" || log_warn "Failed to enable linger (may need sudo)"
        else
            log_warn "loginctl not found, skipping linger setup"
        fi

        # Reload systemd user daemon
        if command_exists systemctl; then
            systemctl --user daemon-reload || log_warn "Failed to reload systemd user daemon"
        fi

        mark_step_completed "systemd_linger_enabled"
    fi

    # Step 6: Install VNC server and dependencies
    if step_completed "vnc_installed"; then
        log_info "VNC server already installed, skipping..."
    else
        log_step "Installing VNC server and desktop environment"

        # Check if we're on a Debian/Ubuntu system
        if command_exists apt-get; then
            log_info "Installing tightvncserver, autocutsel, dbus-x11..."
            sudo apt-get update
            sudo apt-get install -y tightvncserver autocutsel dbus-x11
        else
            log_warn "apt-get not found. Please manually install: tightvncserver autocutsel dbus-x11"
        fi

        mark_step_completed "vnc_installed"
    fi

    # Step 7: Configure VNC server
    if step_completed "vnc_configured"; then
        log_info "VNC server already configured, skipping..."
    else
        log_step "Configuring VNC server"

        # Create VNC directory
        mkdir -p "$HOME/.vnc"

        # Configure VNC password if VNC_PASSWORD environment variable is set
        if [ -n "$VNC_PASSWORD" ]; then
            log_info "Setting VNC password from VNC_PASSWORD environment variable..."
            echo "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
            chmod 600 "$HOME/.vnc/passwd"
        else
            log_warn "VNC_PASSWORD not set. Password will be prompted on first VNC connection"
        fi

        # Create xstartup script for VNC
        log_info "Creating VNC xstartup configuration..."
        cat > "$HOME/.vnc/xstartup" <<'EOF'
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
# hack to allow sudo in vncviewer:
xhost +localhost
xrdb $HOME/.Xresources
autocutsel -fork
sleep 2
startxfce4 &
EOF
        chmod +x "$HOME/.vnc/xstartup"
        log_info "VNC xstartup configured"

        # Create systemd service file
        local vnc_service="/etc/systemd/system/vncserver@.service"

        if [ -f "$vnc_service" ]; then
            log_info "VNC service file already exists"
        else
            log_info "Creating VNC server systemd service..."
            sudo tee "$vnc_service" > /dev/null <<EOF
[Unit]
Description=Start VNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$(whoami)
Group=$(id -gn)
WorkingDirectory=$HOME
PIDFile=$HOME/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF
            log_info "VNC service file created"
        fi

        # Reload systemd daemon
        sudo systemctl daemon-reload

        mark_step_completed "vnc_configured"
    fi

    # Step 8: Install OpenClaw
    if step_completed "openclaw_installed"; then
        log_info "OpenClaw already installed, skipping..."
    else
        log_step "Installing OpenClaw"

        # Source nvm to ensure we have the right node version
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        # Install openclaw globally using pnpm
        export PATH="$HOME/.local/share/pnpm:$PATH"

        if command_exists openclaw; then
            log_info "OpenClaw command already available"
        else
            log_info "Installing OpenClaw globally with pnpm..."
            pnpm add -g openclaw
        fi

        mark_step_completed "openclaw_installed"
    fi

    # Step 9: Setup OpenClaw browser extension
    if step_completed "browser_extension_setup"; then
        log_info "Browser extension already set up, skipping..."
    else
        log_step "Setting up OpenClaw browser extension"

        if [ -d "$HOME/.openclaw/browser/chrome-extension" ]; then
            # Create symlink for easy access
            if [ ! -L "$HOME/openclaw-extension" ]; then
                ln -s "$HOME/.openclaw/browser/chrome-extension" "$HOME/openclaw-extension"
                log_info "Browser extension symlinked to ~/openclaw-extension"
            fi
        else
            log_warn "Browser extension not found at expected location. It will be created when OpenClaw runs."
        fi

        mark_step_completed "browser_extension_setup"
    fi

    # Step 10: Start VNC server
    if step_completed "vnc_started"; then
        log_info "VNC server already started, skipping..."
    else
        log_step "Starting VNC server"

        # Check if VNC server is already running
        if pgrep -f "Xvnc :1" >/dev/null 2>&1; then
            log_info "VNC server already running"
        else
            # Start VNC server manually first time
            if command_exists vncserver; then
                log_info "Starting VNC server on display :1..."
                vncserver :1 -geometry 1920x1080 -depth 24 || log_warn "VNC server may already be running"
            fi

            # Enable and start the systemd service
            if command_exists systemctl; then
                sudo systemctl enable vncserver@1 || log_warn "Failed to enable VNC service"
                sudo systemctl start vncserver@1 || log_warn "Failed to start VNC service"

                # Check status
                log_info "VNC server status:"
                sudo systemctl status vncserver@1 --no-pager || true
            fi
        fi

        mark_step_completed "vnc_started"
    fi

    # Final steps and information
    log_step "Installation Complete!"

    echo ""
    log_info "OpenClaw has been installed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Source your shell profile or restart your terminal:"
    echo "     source ~/.bashrc"
    echo ""
    echo "  2. Run OpenClaw:"
    echo "     openclaw"
    echo ""
    echo "  3. Access the VNC server at localhost:5901"
    echo "     Password will be prompted on first VNC connection"
    echo ""
    echo "  4. Load the browser extension from:"
    echo "     ~/openclaw-extension"
    echo "     (or $HOME/.openclaw/browser/chrome-extension)"
    echo ""
    echo "  5. For OpenClaw documentation, visit:"
    echo "     https://docs.openclaw.ai/"
    echo ""

    # Show environment info
    log_info "Installation summary:"
    echo "  - Node version: $(node --version 2>/dev/null || echo 'not in current PATH')"
    echo "  - pnpm version: $(pnpm --version 2>/dev/null || echo 'not in current PATH')"
    echo "  - OpenClaw: $(command -v openclaw 2>/dev/null || echo 'not in current PATH')"
    echo "  - VNC Display: :1 (port 5901)"
    echo ""

    log_warn "Please restart your terminal or run 'source ~/.bashrc' to update your PATH"
}

# Run main installation
main "$@"

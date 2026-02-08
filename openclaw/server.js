#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const PORT = process.env.PORT || 3000;
const HOSTNAME = process.env.HOSTNAME || '0.0.0.0';

// Check if OpenClaw is installed
function checkOpenClawInstalled() {
  return new Promise((resolve) => {
    exec('which openclaw', (error) => {
      resolve(!error);
    });
  });
}

// Check if VNC server is running
function checkVNCRunning() {
  return new Promise((resolve) => {
    exec('pgrep -f "Xvnc :1"', (error) => {
      resolve(!error);
    });
  });
}

// Get installation progress
function getInstallationProgress() {
  return new Promise((resolve) => {
    const installDir = path.join(process.env.HOME, '.openclaw-install');
    if (!fs.existsSync(installDir)) {
      resolve([]);
      return;
    }

    fs.readdir(installDir, (err, files) => {
      if (err) {
        resolve([]);
      } else {
        resolve(files);
      }
    });
  });
}

// Generate the HTML page
async function generateHTML() {
  const openClawInstalled = await checkOpenClawInstalled();
  const vncRunning = await checkVNCRunning();
  const completedSteps = await getInstallationProgress();

  const totalSteps = 10;
  const progress = Math.round((completedSteps.length / totalSteps) * 100);

  const statusBadge = openClawInstalled
    ? '<span class="status-badge installed">✓ Installed</span>'
    : '<span class="status-badge installing">⟳ Installing...</span>';

  const vncBadge = vncRunning
    ? '<span class="status-badge running">✓ VNC Running</span>'
    : '<span class="status-badge stopped">○ VNC Stopped</span>';

  return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OpenClaw - Installation Status</title>
    <link rel="icon" href="https://avatars.githubusercontent.com/u/252820863" type="image/png">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: #333;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            width: 100%;
            overflow: hidden;
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px;
            text-align: center;
            color: white;
        }

        .logo {
            width: 80px;
            height: 80px;
            border-radius: 16px;
            margin-bottom: 20px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        h1 {
            font-size: 2.5em;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .tagline {
            font-size: 1.1em;
            opacity: 0.95;
            font-weight: 300;
        }

        .content {
            padding: 40px;
        }

        .status-section {
            margin-bottom: 30px;
        }

        .status-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .status-title {
            font-size: 1.3em;
            font-weight: 600;
            color: #333;
        }

        .status-badges {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
            display: inline-block;
        }

        .status-badge.installed {
            background: #10b981;
            color: white;
        }

        .status-badge.installing {
            background: #f59e0b;
            color: white;
            animation: pulse 2s ease-in-out infinite;
        }

        .status-badge.running {
            background: #3b82f6;
            color: white;
        }

        .status-badge.stopped {
            background: #6b7280;
            color: white;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

        .progress-bar {
            background: #e5e7eb;
            border-radius: 10px;
            height: 8px;
            overflow: hidden;
            margin-bottom: 10px;
        }

        .progress-fill {
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            height: 100%;
            transition: width 0.5s ease;
            border-radius: 10px;
        }

        .progress-text {
            font-size: 0.9em;
            color: #6b7280;
            text-align: right;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }

        .info-card {
            background: #f9fafb;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e5e7eb;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .info-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .info-card h3 {
            font-size: 1.1em;
            margin-bottom: 10px;
            color: #667eea;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-card p {
            color: #6b7280;
            line-height: 1.6;
            font-size: 0.95em;
        }

        .info-card code {
            background: #e5e7eb;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.9em;
            color: #dc2626;
        }

        .links {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 30px;
            padding-top: 30px;
            border-top: 1px solid #e5e7eb;
        }

        .link-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        }

        .link-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
        }

        .link-btn.secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
            box-shadow: none;
        }

        .link-btn.secondary:hover {
            background: #f9fafb;
        }

        .footer {
            text-align: center;
            padding: 20px;
            background: #f9fafb;
            color: #6b7280;
            font-size: 0.9em;
        }

        .icon {
            font-size: 1.2em;
        }

        @media (max-width: 600px) {
            h1 {
                font-size: 2em;
            }

            .content {
                padding: 20px;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="https://avatars.githubusercontent.com/u/252820863" alt="OpenClaw Logo" class="logo">
            <h1>OpenClaw</h1>
            <p class="tagline">Your Personal AI Assistant Platform</p>
        </div>

        <div class="content">
            <div class="status-section">
                <div class="status-header">
                    <div class="status-title">Installation Status</div>
                    <div class="status-badges">
                        ${statusBadge}
                        ${vncBadge}
                    </div>
                </div>

                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progress}%"></div>
                </div>
                <div class="progress-text">${progress}% Complete (${completedSteps.length}/${totalSteps} steps)</div>
            </div>

            <div class="info-grid">
                <div class="info-card">
                    <h3><span class="icon">🚀</span> Quick Start</h3>
                    <p>Once installation is complete, run:<br><code>openclaw</code></p>
                </div>

                <div class="info-card">
                    <h3><span class="icon">🖥️</span> VNC Access</h3>
                    <p>Browser control via VNC:<br><code>localhost:5901</code></p>
                </div>

                <div class="info-card">
                    <h3><span class="icon">🔧</span> Configuration</h3>
                    <p>Set your API keys in:<br><code>~/.env</code></p>
                </div>

                <div class="info-card">
                    <h3><span class="icon">🔌</span> Browser Extension</h3>
                    <p>Load from:<br><code>~/openclaw-extension</code></p>
                </div>
            </div>

            <div class="links">
                <a href="https://docs.openclaw.ai/" class="link-btn" target="_blank">
                    <span class="icon">📚</span> Documentation
                </a>
                <a href="https://github.com/openclaw/openclaw" class="link-btn secondary" target="_blank">
                    <span class="icon">⭐</span> GitHub
                </a>
                <a href="https://openclaw.io/" class="link-btn secondary" target="_blank">
                    <span class="icon">🌐</span> Website
                </a>
            </div>
        </div>

        <div class="footer">
            OpenClaw - Self-Hosted AI Assistant<br>
            Integrates with WhatsApp, Telegram, Slack, Discord, and more
        </div>
    </div>

    <script>
        // Auto-refresh every 10 seconds during installation
        const progress = ${progress};
        if (progress < 100) {
            setTimeout(() => location.reload(), 10000);
        }
    </script>
</body>
</html>`;
}

// Create the HTTP server
async function startServer() {
  const server = http.createServer(async (req, res) => {
    if (req.url === '/' || req.url === '/index.html') {
      const html = await generateHTML();
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(html);
    } else if (req.url === '/health') {
      const openClawInstalled = await checkOpenClawInstalled();
      const vncRunning = await checkVNCRunning();
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status: 'ok',
        openclaw: openClawInstalled,
        vnc: vncRunning
      }));
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not Found');
    }
  });

  server.listen(PORT, HOST, () => {
    console.log(`\n🚀 OpenClaw Status Server running at http://${HOST}:${PORT}/`);
    console.log(`📊 Health check available at http://${HOST}:${PORT}/health\n`);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('\n📴 Shutting down gracefully...');
    server.close(() => {
      console.log('✓ Server closed');
      process.exit(0);
    });
  });

  process.on('SIGINT', () => {
    console.log('\n📴 Shutting down gracefully...');
    server.close(() => {
      console.log('✓ Server closed');
      process.exit(0);
    });
  });
}

// Start the server
startServer().catch(err => {
  console.error('Failed to start server:', err);
  process.exit(1);
});

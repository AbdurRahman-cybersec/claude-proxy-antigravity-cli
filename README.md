![Platform](https://img.shields.io/badge/platform-Windows-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-stable-success)
![Claude](https://img.shields.io/badge/Claude-Opus%204.5-orange)

# Claude CLI (PowerShell) — Antigravity Proxy Client

A **single‑file** interactive PowerShell chat client for Claude that talks to a local **Antigravity Claude Proxy** via the Anthropic‑compatible **`/v1/messages`** API.

You do **not** need to clone this repository or install it as a package. Downloading the `.ps1` file is enough.

---

## Features
- Single PowerShell script (no build step)
- Interactive chat loop
- Model picker (default: `claude-opus-4-5-thinking`)
- Conversation memory across turns
- Built‑in commands:
  - `/exit` — quit
  - `/reset` — clear conversation history
  - `/save [path]` — save transcript
- Optional convenience behavior:
  - Automatically starts the Antigravity proxy via `npx` if not running
  - Opens the proxy dashboard (`http://localhost:8080`) in your browser

---

## Requirements
- Windows
- PowerShell 5.1+ or PowerShell 7+
- Node.js (only required so `npx` can start the proxy)
- **Access to Antigravity Claude Proxy**  
  (The script can start it automatically if not already running)

---

## Quick Start (No Git Clone Required)

1. Download **`claude-cli.ps1`** from this repository.
2. Open PowerShell in the download folder.
3. Run (one‑time, standard PowerShell setting):

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

4. Run the script:

```powershell
powershell -ExecutionPolicy Bypass -File .\claude-cli.ps1
```

That’s it — the CLI will start and prompt you for input.

---

## What Happens on Startup

When launched, the script may:
- Check whether the Antigravity proxy is reachable on port `8080`
- Launch the proxy in a new PowerShell window if it is not running
- Open `http://localhost:8080` in your default browser
- Prompt you to select a Claude model (press Enter to use the default)

---

## Commands

Available inside the CLI:

- `/reset` — clears conversation history
- `/save` — saves the transcript to the default directory
- `/save C:\path\to\file.txt` — saves the transcript to a custom path
- `/exit` — exits the program

---

## Configuration

The script uses the following defaults:

- Endpoint: `http://localhost:8080/v1/messages`
- HTTP header: `x-api-key: local-placeholder-key`

The API key value is a **placeholder** and is ignored by the local proxy. No real API keys are required by default.

---

## Safety and Privacy Notes

- This repository contains **no real API keys, tokens, or credentials**.
- Chat transcripts may contain sensitive content. If you save transcripts locally, handle them accordingly.
- The script may open a browser window and spawn a new PowerShell process to start the proxy.

---



## Security & Privacy Review

### No secrets detected
The script does **not** include:
- API keys
- Authentication tokens
- Email addresses
- Account identifiers

### Non‑sensitive but noteworthy behavior
These are intentional and documented:
- Auto‑starting the proxy using `npx antigravity-claude-proxy@latest start`
- Opening the local dashboard at `http://localhost:8080`
- Saving transcripts to a local directory


---

## Screenshots

### Antigravity Proxy Server
The local Antigravity proxy running and ready to accept requests.

![Antigravity Proxy Server](screenshots/antigravity-proxy-server.png)

---

### Claude CLI (PowerShell)
Interactive Claude chat running via the local Antigravity proxy.

![Claude CLI](screenshots/claude-proxy-cli.png)

---

### Localhost Web Dashboard
The Antigravity web dashboard available at `http://localhost:8080`.

![Localhost Web](screenshots/localhost-web.png)

## License

MIT License

Copyright (c) 2026 Abdur Rahman Khan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

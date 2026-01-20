# claude-cli.ps1
# Minimal interactive chat client for Claude Opus via local Antigravity proxy.

$endpoint = "http://localhost:8080/v1/messages"
$headers = @{
    "x-api-key"   = "local-placeholder-key"
    "Content-Type" = "application/json"
}
$defaultSaveDir = "C:\Tools\chat-saves"
$script:OrangeColor = "$([char]27)[38;2;191;116;4m"
$script:ResetColor = "$([char]27)[0m"
$availableModels = @(
    [pscustomobject]@{ Label = "Claude Opus 4.5 (thinking)"; Value = "claude-opus-4-5-thinking" },
    [pscustomobject]@{ Label = "Claude Sonnet 3.5 (example)"; Value = "claude-sonnet-3-5" },
    [pscustomobject]@{ Label = "Claude Haiku 3.5 (example)"; Value = "claude-haiku-3-5" }
)

function Write-OrangeLine {
    param([string]$Text)
    Write-Host ($script:OrangeColor + $Text + $script:ResetColor)
}

function Test-ProxyReady {
    param(
        [int]$Port = 8080,
        [int]$TimeoutMs = 500
    )

    $client = New-Object System.Net.Sockets.TcpClient
    $waitHandle = $null
    try {
        $async = $client.BeginConnect("localhost", $Port, $null, $null)
        $waitHandle = $async.AsyncWaitHandle
        if (-not $waitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }
        $client.EndConnect($async) | Out-Null
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($waitHandle) { $waitHandle.Close() }
        $client.Dispose()
    }
}

function Start-ProxyIfNeeded {
    param(
        [string]$ProxyCommand = "npx antigravity-claude-proxy@latest start"
    )

    if (Test-ProxyReady) {
        Write-Host "Antigravity proxy already reachable at http://localhost:8080.`n"
        return
    }

    Write-Host "Launching Antigravity proxy in a new PowerShell window..."
    try {
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-Command", $ProxyCommand | Out-Null
    }
    catch {
        Write-Warning "Unable to start proxy window: $($_.Exception.Message)"
        return
    }

    $maxWaitSeconds = 20
    $elapsed = 0
    while ($elapsed -lt $maxWaitSeconds) {
        if (Test-ProxyReady) {
            Write-Host "Proxy is up. Continuing with chat client.`n"
            return
        }
        Start-Sleep -Seconds 1
        $elapsed++
    }

    Write-Warning "Proxy has not responded on port 8080 yet; continuing anyway."
}

function Open-ProxyDashboard {
    param(
        [string]$Url = "http://localhost:8080"
    )

    try {
        Start-Process -FilePath "chrome.exe" -ArgumentList $Url | Out-Null
        Write-Host "Opened Chrome to $Url`n"
    }
    catch {
        Write-Warning "Could not launch Chrome automatically ($($_.Exception.Message)). Trying default browser..."
        try {
            Start-Process -FilePath $Url | Out-Null
        }
        catch {
            Write-Warning "Unable to open a browser automatically. Please visit $Url manually."
        }
    }
}

function Select-Model {
    param(
        [array]$Options,
        [string]$DefaultValue
    )

    if (-not $Options -or $Options.Count -eq 0) {
        Write-Warning "No predefined models configured; defaulting to $DefaultValue."
        return $DefaultValue
    }

    Write-Host "Available Claude models:"
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $entry = $Options[$i]
        $displayIndex = $i + 1
        Write-Host ("  {0}. {1} [{2}]" -f $displayIndex, $entry.Label, $entry.Value)
    }
    Write-Host "Enter a number or custom model id. Press Enter for default (1 / Opus)."

    $choice = Read-Host "Model choice"
    if ([string]::IsNullOrWhiteSpace($choice)) {
        return $DefaultValue
    }

    if ($choice -match "^\d+$") {
        $index = [int]$choice - 1
        if ($index -ge 0 -and $index -lt $Options.Count) {
            return $Options[$index].Value
        }
        Write-Warning "Selection $choice is out of range; sticking with $DefaultValue."
        return $DefaultValue
    }

    return $choice.Trim()
}

function Show-ClaudeDashboard {
    param(
        [string]$ModelName
    )

    $art = @(
        "   ____ _                 _        ____ _     ___ ",
        "  / ___| | ___  _   _  __| | ___  / ___| |   |_ _|",
        " | |   | |/ _ \| | | |/ _` |/ _ \| |   | |    | | ",
        " | |___| | (_) | |_| | (_| | (_) | |___| |___ | | ",
        "  \____|_|\___/ \__,_|\__,_|\___/ \____|_____|___|"
    )

    $border = "======================================================================="
    Write-Host ""
    Write-OrangeLine "Claude CLI v1.0"
    $art | ForEach-Object { Write-OrangeLine $_ }
    Write-OrangeLine $border
    Write-OrangeLine ("Connected model : {0}" -f $ModelName)
    Write-OrangeLine "Tips            : /save writes to C:\Tools\chat-saves"
    Write-OrangeLine "Commands        : /reset clears history, /exit quits"
    Write-OrangeLine $border
    Write-OrangeLine "Say hi to Claude below!"
    Write-Host ""
}

function Save-Transcript {
    param(
        [Parameter(Mandatory = $true)]
        [array]$History,
        [string]$PathOverride
    )

    if (-not $History -or $History.Count -eq 0) {
        Write-Host "Nothing to save yet. Start chatting first.`n"
        return
    }

    $targetPath = $PathOverride
    if ([string]::IsNullOrWhiteSpace($targetPath)) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $targetPath = Join-Path $defaultSaveDir "claude-chat-$timestamp.txt"
    }

    $lines = @()
    foreach ($message in $History) {
        $roleLabel = if ($message.role -eq "assistant") { "Claude" } else { "You" }
        $textParts = ($message.content | ForEach-Object { $_.text }) -join "`n"
        $lines += ("{0}:" -f $roleLabel)
        $lines += $textParts
        $lines += ""
    }

    try {
        $directory = Split-Path $targetPath -Parent
        if ($directory -and -not (Test-Path $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        [System.IO.File]::WriteAllLines($targetPath, $lines)
        Write-Host "Saved conversation to $targetPath`n"
    }
    catch {
        Write-Warning "Failed to save conversation: $($_.Exception.Message)"
    }
}

Start-ProxyIfNeeded
Open-ProxyDashboard

$defaultModel = $availableModels[0].Value
$modelName = Select-Model -Options $availableModels -DefaultValue $defaultModel
if ([string]::IsNullOrWhiteSpace($modelName)) {
    $modelName = $defaultModel
}
Write-Host "Using Claude model: $modelName`n"
Show-ClaudeDashboard -ModelName $modelName

$history = @()

Write-Host "Claude CLI ready. Use /exit to quit, /reset to clear history, /save [path] to archive.`n"

while ($true) {
    $userInput = Read-Host "You"

    if ($userInput -match "^\s*/exit\s*$") {
        Write-Host "Bye!"
        break
    }

    if ($userInput -match "^\s*/reset\s*$") {
        $history = @()
        Write-Host "History cleared.`n"
        continue
    }

    if ($userInput -match "^\s*/save(?:\s+(.*))?$") {
        $pathArgument = $null
        if ($Matches[1]) { $pathArgument = $Matches[1].Trim() }
        Save-Transcript -History $history -PathOverride $pathArgument
        continue
    }

    if ([string]::IsNullOrWhiteSpace($userInput)) {
        continue
    }

    $userMessage = [pscustomobject]@{
        role    = "user"
        content = @(@{ type = "text"; text = $userInput })
    }

    $pendingHistory = @()
    if ($history) { $pendingHistory += $history }
    $pendingHistory += $userMessage

    $payload = @{
        model      = $modelName
        max_tokens = 1024
        messages   = $pendingHistory
    }

    try {
        $response = Invoke-RestMethod -Method Post -Uri $endpoint -Headers $headers -Body ($payload | ConvertTo-Json -Depth 10)

        $assistantMessage = ($response.content | Where-Object { $_.type -eq "text" } | Select-Object -First 1).text
        if (-not $assistantMessage) { $assistantMessage = "[No text content received.]" }

        Write-Host ""
        Write-OrangeLine "Claude:"
        Write-Host $assistantMessage
        Write-Host ""

        $assistantEntry = [pscustomobject]@{
            role    = "assistant"
            content = @(@{ type = "text"; text = $assistantMessage })
        }

        $history = @()
        if ($pendingHistory) { $history += $pendingHistory }
        $history += $assistantEntry
    }
    catch {
        Write-Warning "Request failed: $($_.Exception.Message)"
    }
}


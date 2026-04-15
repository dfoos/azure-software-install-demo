#Requires -Version 5.1
# ─────────────────────────────────────────────────────────────────────────────
# Example install script — Windows
# Repo location: scripts/<AppName>/install.ps1
#
# Called by the Azure Function via Azure Run Command (equivalent of SSM
# send-command with a RunPowerShellScript document).
#
# Environment variables injected by the Function bootstrap:
#   $env:APP_NAME       — VM tag value for AppName (e.g. "security-agent")
#   $env:GITHUB_ORG     — GitHub organization
#   $env:GITHUB_REPO    — GitHub repository
#   $env:GITHUB_BRANCH  — Branch
#
# Azure IMDS provides region, subscription, etc. at runtime — no credentials
# needed for Azure API access if the VM has a Managed Identity.
# ─────────────────────────────────────────────────────────────────────────────
$ErrorActionPreference = 'Stop'

$LogFile = "C:\Windows\Temp\vm-software-install.log"

# Ensure log directory exists and file is writable before any other work
$null = New-Item -ItemType Directory -Path (Split-Path $LogFile) -Force -ErrorAction SilentlyContinue
$null = New-Item -ItemType File     -Path $LogFile               -Force -ErrorAction SilentlyContinue

function Write-Log {
    param([string]$Message)
    $line = "{0} {1}" -f (Get-Date -Format 'u'), $Message
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

$AppName = if ($env:APP_NAME) { $env:APP_NAME } else { 'default' }
Write-Log "──────────────────────────────────────────────────"
Write-Log " VM Software Install | app=$AppName"
Write-Log "──────────────────────────────────────────────────"

# ── Read region + subscription from IMDS ─────────────────────────────────────
$ImdsHeaders  = @{ Metadata = "true" }
$ImdsBase     = "http://169.254.169.254/metadata/instance/compute"
$ImdsQuery    = "?api-version=2021-12-13&format=text"

$r              = Invoke-RestMethod -Uri "${ImdsBase}/location${ImdsQuery}"          -Headers $ImdsHeaders -ErrorAction SilentlyContinue
$Region         = if ($r) { $r } else { 'unknown' }
$r              = Invoke-RestMethod -Uri "${ImdsBase}/subscriptionId${ImdsQuery}"    -Headers $ImdsHeaders -ErrorAction SilentlyContinue
$SubscriptionId = if ($r) { $r } else { 'unknown' }
$r              = Invoke-RestMethod -Uri "${ImdsBase}/resourceGroupName${ImdsQuery}" -Headers $ImdsHeaders -ErrorAction SilentlyContinue
$ResourceGroup  = if ($r) { $r } else { 'unknown' }
$r              = Invoke-RestMethod -Uri "${ImdsBase}/name${ImdsQuery}"              -Headers $ImdsHeaders -ErrorAction SilentlyContinue
$VmName         = if ($r) { $r } else { 'unknown' }

Write-Log "Region:         $Region"
Write-Log "Subscription:   $SubscriptionId"
Write-Log "Resource Group: $ResourceGroup"
Write-Log "VM Name:        $VmName"

# ── Example: install and configure a security agent ──────────────────────────
# Replace this block with your actual tooling. Configuration is
# region/environment-aware at install time — no need to bake it into the image.

Write-Log "Installing $AppName..."

# Placeholder: download your vendor's Windows installer
# $AgentUrl = "https://your-repo.example.com/agent/latest/windows/agent.msi"
# $InstallerPath = "$env:TEMP\agent.msi"
# Invoke-WebRequest -Uri $AgentUrl -OutFile $InstallerPath
# Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /quiet /norestart" -Wait -PassThru | Out-Null

# Placeholder: configure the agent with the correct regional endpoint
# & "C:\Program Files\VendorAgent\configure.exe" `
#     --management-server "https://manage.$Region.your-service.example.com" `
#     --subscription-id  $SubscriptionId `
#     --group            $ResourceGroup

# Placeholder: ensure the service is running
# Start-Service VendorAgentService -ErrorAction SilentlyContinue
# Set-Service  VendorAgentService -StartupType Automatic

Write-Log "Install complete"

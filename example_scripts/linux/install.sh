#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Example install script — Linux
# Repo location: scripts/<AppName>/install.sh
#
# Called by the Azure Function via Azure Run Command (equivalent of SSM
# send-command with a RunShellScript document).
#
# Environment variables injected by the Function bootstrap:
#   APP_NAME       — VM tag value for AppName (e.g. "security-agent")
#   GITHUB_ORG     — GitHub organization
#   GITHUB_REPO    — GitHub repository
#   GITHUB_BRANCH  — Branch
#
# Azure Instance Metadata Service (IMDS) provides region, subscription, etc.
# No credentials are needed — the VM uses its own Managed Identity for
# anything requiring Azure API access.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

LOG_FILE="/var/log/vm-software-install.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "──────────────────────────────────────────────────"
echo " VM Software Install | app=${APP_NAME:-default}"
echo " Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "──────────────────────────────────────────────────"

# ── Read region + subscription from IMDS ─────────────────────────────────────
IMDS_BASE="http://169.254.169.254/metadata/instance/compute"
IMDS_API="api-version=2021-12-13&format=text"

REGION=$(curl -sf -H "Metadata:true" "${IMDS_BASE}/location?${IMDS_API}" || echo "unknown")
SUBSCRIPTION_ID=$(curl -sf -H "Metadata:true" "${IMDS_BASE}/subscriptionId?${IMDS_API}" || echo "unknown")
RESOURCE_GROUP=$(curl -sf -H "Metadata:true" "${IMDS_BASE}/resourceGroupName?${IMDS_API}" || echo "unknown")
VM_NAME=$(curl -sf -H "Metadata:true" "${IMDS_BASE}/name?${IMDS_API}" || echo "unknown")

echo "Region:        ${REGION}"
echo "Subscription:  ${SUBSCRIPTION_ID}"
echo "Resource Group:${RESOURCE_GROUP}"
echo "VM Name:       ${VM_NAME}"

# ── Example: install and configure a security agent ──────────────────────────
# Replace this block with your actual tooling.  The key win vs baking into an
# AMI/image: configuration is region/environment-aware at install time.

echo "Installing ${APP_NAME:-default}..."

apt-get update -qq
apt-get install -y -qq curl jq

# Placeholder: download and run your vendor's installer
# AGENT_INSTALLER_URL="https://your-repo.example.com/agent/latest/linux/agent.deb"
# curl -fsSL -o /tmp/agent.deb "${AGENT_INSTALLER_URL}"
# dpkg -i /tmp/agent.deb

# Placeholder: configure the agent with the correct regional endpoint
# /opt/vendor-agent/bin/configure \
#   --management-server "https://manage.${REGION}.your-service.example.com" \
#   --subscription-id  "${SUBSCRIPTION_ID}" \
#   --group            "${RESOURCE_GROUP}"

# Placeholder: enable and start the service
# systemctl enable --now vendor-agent

echo "Install complete: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

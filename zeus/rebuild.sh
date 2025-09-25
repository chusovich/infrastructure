#!/usr/bin/env bash

set -euo pipefail

# Step 1: Build NixOS flake
echo "🔨 Building NixOS configuration..."
cp /home/calebh/infrastructure/zeus/configuration.nix /etc/nixos/configuration.nix
cp /home/calebh/infrastructure/zeus/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
sudo nixos-rebuild switch # -f /home/calebh/infrastructure/zeus/configuration.nix

# Step 2: Commit any changes in current Git repo
echo "📦 Committing changes to Git..."
git add --all
gen=$(nixos-rebuild list-generations | grep current)
git commit -m "Commting generation $gen" || echo "Nothing to commit."

# Step 3: Run garbage collection
echo "🧹 Running Nix garbage collection..."
nix-collect-garbage

echo "✅ Done!"
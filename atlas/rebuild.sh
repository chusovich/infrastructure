#!/usr/bin/env bash

set -euo pipefail

# Step 1: Build NixOS
echo "🔨 Building NixOS configuration..."
cp /home/calebh/infrastructure/atlas/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch 

# Step 2: Commit any changes in current Git repo
echo "📦 Committing changes to Git..."
git add --all
gen=$(nixos-rebuild list-generations | grep current)
git commit -m "Commting generation $gen" || echo "Nothing to commit."

# Step 3: Run garbage collection
echo "🧹 Running Nix garbage collection..."
nix-collect-garbage

echo "✅ Done!"
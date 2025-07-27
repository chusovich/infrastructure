#!/usr/bin/env bash

set -euo pipefail

# Step 1: Build NixOS flake
echo "🔨 Building NixOS configuration..."
nixos-rebuild switch -I /home/calebh/infrastructure/atlas/configuration.nix

# Step 2: Commit any changes in current Git repo
echo "📦 Committing changes to Git..."
git add .
gen=$(nixos-rebuild list-generations | grep current)
git commit -m "Commting generation $gen" || echo "Nothing to commit."

# Step 3: Run garbage collection
# echo "🧹 Running Nix garbage collection..."
# sudo nh clean all --keep 5

echo "✅ Done!"
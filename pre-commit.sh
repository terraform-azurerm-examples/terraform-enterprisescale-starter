#!/bin/sh
set -eu

if [ ! $(command -v terraform) ]; then
  echo "Could not find terraform"
  exit 1
fi

# Stash unstaged changes
STASH_NAME="pre-commit-$(date +%s)"
git stash push -q --keep-index -m $STASH_NAME

# Test Terraform
terraform fmt -check -recursive
terraform validate

# Retrieve stash
STASHES=$(git stash list | grep 'stash@{0}' | grep $STASH_NAME)
if [ "$STASHES" ]; then
  git stash pop -q
fi

exit 0
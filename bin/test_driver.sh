#!/usr/bin/env bash

driver=$1
project_path="examples/${driver}_project"

if [ ! -d "${project_path}" ]; then
  echo "Unknown driver ${driver}"
  exit 1;
fi

function cleanup {
  rm -rf .git
  rm -rf *.tar.gz
}

trap cleanup EXIT

cd "${project_path}"

# prepare current "project"
git config --global user.email "mate@mate.dev"
git config --global user.name "Mate Dev"
git init
git add .
git commit -m 'test project'

# get deps
mix deps.get
mix compile

# run build pipeline only (no deploy)
mix mate.build

# check result
if [ -f *.tar.gz ]; then
  echo "Success, created release archive with ${driver}"
  exit 0
else
  echo "Driver ${driver} failed to create tarball."
  exit 1
fi

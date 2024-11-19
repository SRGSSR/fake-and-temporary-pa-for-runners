#!/bin/bash

set -e

eval "$(pkgx --shellcode)"
env +swiftlint +shellcheck +markdownlint +yamllint

echo "... checking Swift code..."
if [ $# -eq 0 ]; then
  swiftlint --quiet --strict
elif [[ "$1" == "only-changes" ]]; then
  git diff --staged --name-only | grep ".swift$" | xargs swiftlint lint --quiet --strict
fi
echo "... checking Ruby scripts..."
echo "... UNCOMMENT ..."
#rubocop --format quiet
echo "... checking Shell scripts..."
shellcheck Scripts/*.sh hooks/* Artifacts/**/*.sh
echo "... checking Markdown documentation..."
markdownlint --ignore fastlane .
echo "... checking YAML files..."
yamllint .*.yml .github

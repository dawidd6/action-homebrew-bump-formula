#!/usr/bin/env bash

set -e

actor="$GITHUB_ACTOR"

token="$INPUT_TOKEN"
formula="$INPUT_FORMULA"
url="$INPUT_URL"
sha256="$INPUT_SHA256"
tag="$INPUT_TAG"
revision="$INPUT_REVISION"
force="$INPUT_FORCE"

if test -z "$formula"; then
    echo "Need to specify the 'formula'"
    exit 1
fi

if test -n "$url" && test -n "$tag"; then
    echo "Can't specify 'url' and 'tag' together"
    exit 1
fi

if test -n "$url" && test -n "$revision"; then
    echo "Can't specify 'url' and 'revision' together"
    exit 1
fi

if test -n "$tag" && test -n "$sha256"; then
    echo "Can't specify 'tag' and 'sha256' together"
    exit 1
fi

if test -n "$revision" && test -n "$sha256"; then
    echo "Can't specify 'revision' and 'sha256' together"
    exit 1
fi

if test -z "$url" && test -z "$tag" && test -z "$revision"; then
    echo "Need to specify 'url' with optional 'sha256', or 'tag' and 'revision'"
    exit 1
fi

if test -z "$tag" && test -n "$revision"; then
    echo "Need to specify 'tag' with 'revision'"
    exit 1
fi

if test -z "$revision" && test -n "$tag"; then
    echo "Need to specify 'revision' with 'tag'"
    exit 1
fi

args=(
    --no-browse
    --no-audit
)

if test -n "$force"; then
    args+=(--force)
fi
if test -n "$url"; then
    args+=(--url="$url")
fi
if test -n "$sha256"; then
    args+=(--sha256="$sha256")
fi
if test -n "$tag"; then
    args+=(--tag="$tag")
fi
if test -n "$revision"; then
    args+=(--revision="$revision")
fi

echo "ARGS: ${args[@]}"

if test -z "$actor"; then
    echo "GITHUB_ACTOR not set"
    exit 1
fi

brew update-reset

if test "$(echo $formula | grep -o / | wc -l)" -eq 2; then
    tap="$(echo $formula | cut -d/ -f1-2)"
    brew tap "$tap"
fi

git config --global user.email "$actor@users.noreply.github.com"
git config --global user.name "$actor"

export HOMEBREW_GITHUB_API_TOKEN="$token"

brew bump-formula-pr "${args[@]}" "$formula"
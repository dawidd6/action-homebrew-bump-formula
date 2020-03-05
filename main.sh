#!/usr/bin/env bash

set -e

actor="$GITHUB_ACTOR"

token="$INPUT_TOKEN"
formula="$INPUT_FORMULA"
url="$INPUT_URL"
tag="$INPUT_TAG"
revision="$INPUT_REVISION"
force="$INPUT_FORCE"

if test -n "$url" && test -n "$tag" && test -n "$revision"; then
    echo "Don't specify 'url', 'tag' and 'revision' together."
    echo "There are 2 options:"
    echo "- specify only 'url'"
    echo "- specify only 'tag' and 'revision'"
    exit 1
fi

if test -z "$url" && test -z "$tag" && test -z "$revision"; then
    echo "Need to specify 'url', or 'tag' and 'revision'"
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

brew update-reset

if test "$(echo $formula | grep -o / | wc -l)" -eq 2; then
    tap="$(echo $formula | cut -d/ -f1-2)"
    brew tap "$tap"
fi

git config --global user.email "$actor@users.noreply.github.com"
git config --global user.name "$actor"

export HOMEBREW_GITHUB_API_TOKEN="$token"

args=(
    --no-browse
    --no-audit
)

if test -n "$force"; then
    args+=(--force)
fi

if test -n "$url"; then
    args+=(--url="$url")
elif test -n "$tag" && test -n "$revision"; then
    args+=(--tag="$tag")
    args+=(--revision="$revision")
fi

brew bump-formula-pr "${args[@]}" "$formula"
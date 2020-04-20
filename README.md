# Homebrew bump formula Github Action

An action that wraps `brew bump-formula-pr` to ease the process of updating the formula on new project releases.

## Usage

One should use the [Personal Access Token](https://github.com/settings/tokens/new?scopes=public_repo) for `token` input to this Action, not the default `GITHUB_TOKEN`, because `brew bump-formula-pr` creates a fork of the formula's tap repository (if needed) and then creates a pull request.

It is best to use this Action when a new tag is pushed:

```yaml
on:
  push:
    tags:
      - '*'
```

because then, the script will extract all needed informations by itself, you just need to specify the following step in your workflow:

```yaml
- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@v2
  with:
    # Github token, required, not the default one
    token: ${{secrets.TOKEN}}
    # Optional, defaults to homebrew/core
    tap: dawidd6/tap
    # Formula name, generally required
    formula: FORMULA
    # Optional, will be determined automatically
    tag: ${{github.ref}}
    # Optional, will be determined automatically
    revision: ${{github.sha}}
    # Optional, if don't want to check for already open PRs
    force: true
```

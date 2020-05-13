# Homebrew bump formula Github Action

An action that wraps `brew bump-formula-pr` to ease the process of updating the formula on new project releases.

Runs on `ubuntu` and `macos`.

## Usage

One should use the [Personal Access Token](https://github.com/settings/tokens/new?scopes=public_repo) for `token` input to this Action, not the default `GITHUB_TOKEN`, because `brew bump-formula-pr` creates a fork of the formula's tap repository (if needed) and then creates a pull request.

> There are two ways to use this Action.

### Standard

Use if you want to simply bump the formula, when a new release happens.

Listen for new tags in workflow:

```yaml
on:
  push:
    tags:
      - '*'
```

The Action will extract all needed informations by itself, you just need to specify the following step in your workflow:

```yaml
- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@v3
  with:
    # Github token, required, not the default one
    token: ${{secrets.TOKEN}}
    # Optional, defaults to homebrew/core
    tap: REPO/NAME
    # Formula name, generally required
    formula: FORMULA
    # Optional, will be determined automatically
    tag: ${{github.ref}}
    # Optional, will be determined automatically
    revision: ${{github.sha}}
    # Optional, if don't want to check for already open PRs
    force: false # true
```

### Livecheck

If `livecheck` input is set to `true`, the Action will run `brew livecheck` to check if formula is outdated or if tap contains outdated formulae and then will run `brew bump-formula-pr` on those formulae with proper arguments to bump them.

Might be a good idea to run this on schedule.

If there are no outdated formulae, the Action will just exit.

```yaml
- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@v3
  with:
    # Github token, required, not the default one
    token: ${{secrets.TOKEN}}
    # Bump all outdated formulae in this tap
    tap: dawidd6/tap
    # Bump only this formula if outdated
    formula: FORMULA
    # Optional, if don't want to check for already open PRs
    force: false # true
    # Need to set this input if wants to use `brew livecheck`
    livecheck: true
```

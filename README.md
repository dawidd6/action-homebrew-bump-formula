# Homebrew bump formula GitHub Action

An action that wraps `brew bump-formula-pr` to ease the process of updating the formula on new project releases.

Works on Ubuntu and macOS runners.

## Usage

One should use the [Personal Access Token](https://github.com/settings/tokens/new?scopes=public_repo,workflow) for `token` input to this Action, not the default `GITHUB_TOKEN`, because `brew bump-formula-pr` creates a fork of the formula's tap repository (if needed) and then creates a pull request.

> There are two ways to use this Action.

### Standard mode

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
    # Required, custom GitHub access token with the 'public_repo' and 'workflow' scopes
    token: ${{secrets.TOKEN}}
    # Optional, will create tap repo fork in organization
    org: ORG
    # Optional, use the origin repository instead of forking
    no_fork: false
    # Optional, defaults to homebrew/core
    tap: USER/REPO
    # Formula name, required
    formula: FORMULA
    # Optional, will be determined automatically
    tag: ${{github.ref}}
    # Optional, will be determined automatically
    revision: ${{github.sha}}
    # Optional, if don't want to check for already open PRs
    force: false # true
```

### Livecheck mode

If `livecheck` input is set to `true`, the Action will run `brew livecheck` to check if any provided formulae are outdated or if tap contains any outdated formulae and then will run `brew bump-formula-pr` on each of those formulae with proper arguments to bump them.

Might be a good idea to run this on schedule in your tap repo, so one gets automated PRs updating outdated formulae.

If there are no outdated formulae, the Action will just exit.

```yaml
- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@v3
  with:
    # Required, custom GitHub access token with only the 'public_repo' scope enabled
    token: ${{secrets.TOKEN}}
    # Optional, will create tap repo fork in organization
    org: ORG
    # Bump all outdated formulae in this tap
    tap: USER/REPO
    # Bump only these formulae if outdated
    formula: FORMULA-1, FORMULA-2, FORMULA-3, ...
    # Optional, if don't want to check for already open PRs
    force: false # true
    # Need to set this input if want to use `brew livecheck`
    livecheck: true
```

If only `tap` input is provided, all formulae in given tap will be checked and bumped if needed.

## Examples

- https://github.com/dawidd6/action-homebrew-bump-formula/blob/master/.github/workflows/test.yml
- https://github.com/dawidd6/ba-bump/blob/master/.github/workflows/bump.yml
- https://github.com/ablinov/declutter/blob/master/.github/workflows/bump_homebrew_formula.yml
- https://github.com/jesseduffield/lazygit/blob/master/.github/workflows/cd.yml
- https://github.com/stephan-hesselmann-by/homebrew-BlueYonder/blob/master/.github/workflows/update-tap.yml
- https://github.com/crunchtime-ali/brew-formula-updater/blob/master/.github/workflows/main.yml
- https://github.com/asciidoc/asciidoc-py3/blob/master/.github/workflows/release.yml
- https://github.com/bow-swift/nef/blob/master/.github/workflows/bump-formula.yml
- https://github.com/dandavison/delta/blob/master/.github/workflows/cd.yml
- https://github.com/GitTools/GitVersion/blob/main/.github/workflows/homebrew.yml
- https://github.com/wormi4ok/evernote2md/blob/master/.github/workflows/publish.yml
- https://github.com/cloudskiff/driftctl/blob/main/.github/workflows/homebrew.yml

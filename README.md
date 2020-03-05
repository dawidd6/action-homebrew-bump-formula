# Homebrew bump formula Github Action

An action that wraps `brew bump-formula-pr` to ease the process of updating the formula on new project releases.

## Usage

One should use the [Personal Access Token](https://github.com/settings/tokens/new?scopes=public_repo) for `token` input to this Action, not the default `GITHUB_TOKEN`, because `brew bump-formula-pr` creates a fork of the formula's tap repository and creates a PR.

It is best to use this Action when a new tag is pushed:

```yaml
on:
  push:
    tags:
      - '*'
```

Example of bumping any formula in any user tap:

```yaml
- name: Get tag
  id: tag
  run: echo "::set-output name=tag::${GITHUB_REF##*/}"

- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@master
  with:
    token: ${{secrets.GITHUB_PAT}}
    formula: USER/REPO/FORMULA
    url: "https://github.com/USER/REPO/archive/${{steps.tag.outputs.tag}}.tar.gz"
```

Example of bumping [`lazygit`](https://github.com/jesseduffield/lazygit) formula in [`Homebrew/homebrew-core`](https://github.com/Homebrew/homebrew-core) tap:

```yaml
- name: Get tag
  id: tag
  run: echo "::set-output name=tag::${GITHUB_REF##*/}"

- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@master
  with:
    token: ${{secrets.GITHUB_PAT}}
    formula: lazygit
    url: "https://github.com/jesseduffield/lazygit/archive/${{steps.tag.outputs.tag}}.tar.gz"
```

... using `url` input because the formula already specifies it:

```ruby
class Lazygit < Formula
  desc "Simple terminal UI for git commands"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/v0.16.2.tar.gz"
  sha256 "76c043e59afc403d7353cdb188ac6850ce4c4125412e291240c787b0187e71c6"
```

Example of bumping [`lazydocker`](https://github.com/jesseduffield/lazdockert) formula in [`Homebrew/homebrew-core`](https://github.com/Homebrew/homebrew-core) tap:

```yaml
- name: Get tag
  id: tag
  run: echo "::set-output name=tag::${GITHUB_REF##*/}"

- name: Update Homebrew formula
  uses: dawidd6/action-homebrew-bump-formula@master
  with:
    token: ${{secrets.GITHUB_PAT}}
    formula: lazydocker
    tag: ${{steps.tag.outputs.tag}}
    revision: ${{github.sha}}
```

... using `tag` and `revision` inputs because the formula already specifies them:

```ruby
class Lazydocker < Formula
  desc "The lazier way to manage everything docker"
  homepage "https://github.com/jesseduffield/lazydocker"
  url "https://github.com/jesseduffield/lazydocker.git",
      :tag      => "v0.8",
      :revision => "cea67bc570daaa757a886813ff3c2763189efef6"
```

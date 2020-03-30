# frozen_string_literal: true

require 'json'

module Homebrew
  module_function

  def brew(*args)
    puts "[command]brew #{args.join(' ')}"
    safe_system('brew', *args)
  end

  # Get inputs
  token = ENV['INPUT_TOKEN']
  formula = ENV['INPUT_FORMULA']
  tag = ENV['INPUT_TAG']
  revision = ENV['INPUT_REVISION']
  tap = ENV['INPUT_TAP']
  force = ENV['INPUT_FORCE']

  # Die if required inputs are not provided
  odie "TOKEN is required" unless token
  odie "FORMULA is required" unless formula
  odie "TAG is required" unless tag

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token
  ENV['HOMEBREW_GIT_NAME'] = ENV['GITHUB_ACTOR']
  ENV['HOMEBREW_GIT_EMAIL'] = "#{ENV['GITHUB_ACTOR']}@users.noreply.github.com"

  # Update Homebrew
  brew 'update-reset'

  # Tap if desired
  if tap
    formula = "#{tap}/#{formula}"
    brew 'tap', tap
  end

  # Get info about formula
  stable = Formula[formula].stable
  is_git = stable.downloader.is_a? GitDownloadStrategy

  # Prepare tag and url
  tag = tag.delete_prefix 'refs/tags/'
  url = stable.url.gsub stable.version.to_s, Version.parse(tag).to_s

  # Finally bump the formula
  brew 'bump-formula-pr',
       '--no-audit',
       '--no-browse',
       '--message=[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)',
       *("--url=#{url}" unless is_git),
       *("--tag=#{tag}" if is_git),
       *("--revision=#{revision}" if is_git),
       *('--force' if force),
       formula
end

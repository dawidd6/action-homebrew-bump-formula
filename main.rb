# frozen_string_literal: true

require 'json'

module Homebrew
  module_function

  def brew(*args)
    puts "[command]brew #{args.join(' ')}"
    return if ENV['DEBUG']

    safe_system('brew', *args)
  end

  def git(*args)
    puts "[command]git #{args.join(' ')}"
    return if ENV['DEBUG']

    safe_system('git', *args)
  end

  # Get inputs
  token = ENV['INPUT_TOKEN']
  formula = ENV['INPUT_FORMULA']
  tag = ENV['INPUT_TAG']
  revision = ENV['INPUT_REVISION']
  tap = ENV['INPUT_TAP']
  force = ENV['INPUT_FORCE']

  # Die if required inputs are not provided
  odie 'TOKEN is required' if token.blank?
  odie 'FORMULA is required' if formula.blank?
  odie 'TAG is required' if tag.blank?

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token

  # Update Homebrew
  brew 'update-reset'

  # Tap if desired
  unless tap.blank?
    formula = "#{tap}/#{formula}"
    brew 'tap', tap
  end

  # Get info about formula
  stable = Formula[formula].stable
  is_git = stable.downloader.is_a? GitDownloadStrategy

  # Prepare tag and url
  tag = tag.delete_prefix 'refs/tags/'
  url = stable.url.gsub stable.version.to_s, Version.parse(tag).to_s

  # Tell git who you are
  git 'config', '--global', 'user.name', ENV['GITHUB_ACTOR']
  git 'config', '--global', 'user.email', "#{ENV['GITHUB_ACTOR']}@users.noreply.github.com"

  # Finally bump the formula
  brew 'bump-formula-pr',
       '--no-audit',
       '--no-browse',
       '--message=[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)',
       *("--url=#{url}" unless is_git),
       *("--tag=#{tag}" if is_git),
       *("--revision=#{revision}" if is_git),
       *('--force' unless force.blank?),
       formula
end

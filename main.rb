# frozen_string_literal: true

require 'json'

module Homebrew
  def run(*cmd)
    puts "[command]#{cmd.join(' ')}"
    safe_system(*cmd)
  end

  def start_group(name)
    puts "##[group]#{name}"
  end

  def end_group
    puts '##[endgroup]'
  end

  # Get inputs
  token = ENV['INPUT_TOKEN']
  formula = ENV['INPUT_FORMULA']
  tap = ENV['INPUT_TAP']
  force = ENV['INPUT_FORCE']
  tag = ENV['INPUT_TAG']
  revision = ENV['INPUT_REVISION']

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token

  # Set git committer details
  ENV['GIT_COMMITTER_NAME'] = ENV['GITHUB_ACTOR']
  ENV['GIT_COMMITTER_EMAIL'] = "#{ENV['GITHUB_ACTOR']}@users.noreply.github.com"

  # Update Homebrew
  start_group('Update Homebrew')
  run('brew', 'update-reset')
  end_group

  # Tap if desired
  if tap
    formula = "#{tap}/#{formula}"
    start_group('Tap repository')
    run('brew', 'tap', tap)
    end_group
  end

  # Get info about formula
  info = JSON.parse(`brew info --json #{formula}`)
  old_version = info.first['versions']['stable']
  new_version = Version.parse(tag)
  stable = info.first['urls']['stable']
  using_git = stable['tag'] && stable['revision']
  url = stable['url']
  url.gsub!(old_version, new_version)
  tag.delete_prefix!('refs/tags/')

  # Finally bump the formula
  start_group('Bump the formula')
  run(
    'brew',
    'bump-formula-pr',
    '--no-audit',
    '--no-browse',
    '--message=[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)',
    *("--url=#{url}" unless using_git),
    *("--tag=#{tag}" if using_git),
    *("--revision=#{revision}" if using_git),
    *('--force' if force),
    formula
  )
  end_group
end

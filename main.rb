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

  # Get GITHUB environment variables
  actor = ENV['GITHUB_ACTOR']
  ref = ENV['GITHUB_REF']
  revision = ENV['GITHUB_SHA']

  # Print stuff
  puts <<~EOS
    actor: #{actor}
    ref: #{ref}
    sha: #{revision}
  EOS

  # Check if pushed ref is a tag
  prefix = 'refs/tags/'
  odie "GITHUB_REF isn't a tag" unless ref.start_with?(prefix)
  tag = ref.delete_prefix(prefix)

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token
  ENV['HOMEBREW_NO_AUTO_UPDATE'] = '1'
  ENV['HOMEBREW_NO_ANALYTICS'] = '1'
  ENV['HOMEBREW_NO_EMOJI'] = '1'

  # Set git committer details
  ENV['GIT_COMMITTER_NAME'] = actor
  ENV['GIT_COMMITTER_EMAIL'] = "#{actor}@users.noreply.github.com"

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
  new_version = Version.new(tag)
  stable = info.first['urls']['stable']
  stable_url = stable['url']
  stable_tag = stable['tag']
  stable_revision = stable['revision']
  using_git = stable_tag && stable_revision

  # Change old version in `url` to the new one if not using git
  url = stable_url.gsub(old_version, new_version) unless using_git

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

# frozen_string_literal: true

module Homebrew
  module_function

  class Object
    def false?
      if self.is_a? String
        self.empty? || self.strip == "false"
      else
        self.nil?
      end
    end
  end

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
  force = ENV['INPUT_FORCE']

  # Die if required inputs are not provided
  odie 'TOKEN is required' if token.blank?
  odie 'FORMULA is required' if formula.blank?
  odie 'TAG is required' if tag.blank?

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token

  # Get user details
  actor = ENV['GITHUB_ACTOR']
  user = GitHub.open_api "#{GitHub::API_URL}/users/#{actor}"
  user_name = user['name'] || actor
  user_email = user['email'] || (
    # https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
    user_created_at = Date.parse user['created_at']
    plus_after_date = Date.parse '2017-07-18'
    need_plus_email = (user_created_at - plus_after_date).positive?
    user_email = "#{actor}@users.noreply.github.com"
    user_email = "#{user['id']}+#{user_email}" if need_plus_email
    user_email
  )

  # Tell git who you are
  git 'config', '--global', 'user.name', user_name
  git 'config', '--global', 'user.email', user_email

  # Update Homebrew
  brew 'update-reset'

  # Tap if desired
  tap = formula[%r{^(.+/.+)/.+$}, 1]
  brew 'tap', tap if tap

  # Get info about formula
  stable = Formula[formula].stable
  is_git = stable.downloader.is_a? GitDownloadStrategy

  # Prepare tag and url
  tag = tag.delete_prefix 'refs/tags/'
  url = stable.url.gsub stable.version, Version.parse(tag)

  # Finally bump the formula
  brew 'bump-formula-pr',
       '--no-audit',
       '--no-browse',
       '--message=[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)',
       *("--url=#{url}" unless is_git),
       *("--tag=#{tag}" if is_git),
       *("--revision=#{revision}" if is_git),
       *('--force' unless force.false?),
       formula
end

# frozen_string_literal: true

require 'formula'

class Object
  def false?
    nil?
  end
end

class String
  def false?
    empty? || strip == 'false'
  end
end

module Homebrew
  module_function

  def print_command(*cmd)
    puts "[command]#{cmd.join(' ').gsub("\n", ' ')}"
  end

  def brew(*args)
    print_command ENV["HOMEBREW_BREW_FILE"], *args
    safe_system ENV["HOMEBREW_BREW_FILE"], *args
  end

  def git(*args)
    print_command ENV["HOMEBREW_GIT"], *args
    safe_system ENV["HOMEBREW_GIT"], *args
  end

  def read_brew(*args)
    print_command ENV["HOMEBREW_BREW_FILE"], *args
    output = `#{ENV["HOMEBREW_BREW_FILE"]} #{args.join(' ')})`.chomp
    unless $CHILD_STATUS.exitstatus == 0
      odie output
    end
  end

  # Get inputs
  message = ENV['HOMEBREW_BUMP_MESSAGE']
  tap = ENV['HOMEBREW_BUMP_TAP']
  formula = ENV['HOMEBREW_BUMP_FORMULA']
  tag = ENV['HOMEBREW_BUMP_TAG']
  revision = ENV['HOMEBREW_BUMP_REVISION']
  force = ENV['HOMEBREW_BUMP_FORCE']
  livecheck = ENV['HOMEBREW_BUMP_LIVECHECK']

  # Check inputs
  if livecheck.false?
    odie "Need 'formula' input specified" if formula.blank?
    odie "Need 'tag' input specified" if tag.blank?
  end

  # Get user details
  user = GitHub.open_api "#{GitHub::API_URL}/user"
  user_id = user['id']
  user_login = user['login']
  user_name = user['name'] || user['login']
  user_email = user['email'] || (
    # https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
    user_created_at = Date.parse user['created_at']
    plus_after_date = Date.parse '2017-07-18'
    need_plus_email = (user_created_at - plus_after_date).positive?
    user_email = "#{user_login}@users.noreply.github.com"
    user_email = "#{user_id}+#{user_email}" if need_plus_email
    user_email
  )

  # Tell git who you are
  git 'config', '--global', 'user.name', user_name
  git 'config', '--global', 'user.email', user_email

  # Tap the tap if desired
  brew 'tap', tap unless tap.blank?

  # Append additional PR message
  message = if message.blank?
              ''
            else
              message + "\n\n"
            end
  message += '[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)'

  # Do the livecheck stuff or not
  if livecheck.false?
    # Change formula name to full name
    formula = tap + '/' + formula if !tap.blank? && !formula.blank?

    # Get info about formula
    stable = Formula[formula].stable
    is_git = stable.downloader.is_a? GitDownloadStrategy

    # Prepare tag and url
    tag = tag.delete_prefix 'refs/tags/'
    version = Version.parse tag
    url = stable.url.gsub stable.version, version

    # Finally bump the formula
    brew 'bump-formula-pr',
         '--no-audit',
         '--no-browse',
         "--message=#{message}",
         *("--version=#{version}" unless is_git),
         *("--url=#{url}" unless is_git),
         *("--tag=#{tag}" if is_git),
         *("--revision=#{revision}" if is_git),
         *('--force' unless force.false?),
         formula
  else
    # Support multiple formulae in input and change to full names if tap
    unless formula.blank?
      formula = formula.split(/[ ,\n]/).reject(&:blank?)
      formula = formula.map { |f| tap + '/' + f } unless tap.blank?
    end

    # Get livecheck info
    json = read_brew 'livecheck',
                     '--quiet',
                     '--newer-only',
                     '--full-name',
                     '--json',
                     *("--tap=#{tap}" if !tap.blank? && formula.blank?),
                     *(formula unless formula.blank?)
    json = JSON.parse json

    # Define error
    err = nil

    # Loop over livecheck info
    json.each do |info|
      # Skip if there is no version field
      next unless info['version']

      # Get info about formula
      formula = info['formula']
      version = info['version']['latest']

      begin
        # Finally bump the formula
        brew 'bump-formula-pr',
             '--no-audit',
             '--no-browse',
             "--message=#{message}",
             "--version=#{version}",
             *('--force' unless force.false?),
             formula
      rescue ErrorDuringExecution => e
        # Continue execution on error, but save the exeception
        err = e
      end
    end

    # Die if error occured
    odie err if err
  end
end

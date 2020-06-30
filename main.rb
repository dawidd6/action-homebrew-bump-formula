# frozen_string_literal: true

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

  def brew(*args)
    puts "[command]brew #{args.join(' ')}"
    return if ENV['DEBUG']

    safe_system 'brew', *args
  end

  def git(*args)
    puts "[command]git #{args.join(' ')}"
    return if ENV['DEBUG']

    safe_system 'git', *args
  end

  def read_brew(*args)
    puts "[command]brew #{args.join(' ')}"
    return if ENV['DEBUG']

    Utils.safe_popen_read('brew', *args).chomp
  end

  def read_git(*args)
    puts "[command]git #{args.join(' ')}"
    return if ENV['DEBUG']

    Utils.safe_popen_read('git', *args).chomp
  end

  # Get inputs
  token = ENV['INPUT_TOKEN']
  tap = ENV['INPUT_TAP']
  formula = ENV['INPUT_FORMULA']
  tag = ENV['INPUT_TAG']
  revision = ENV['INPUT_REVISION']
  force = ENV['INPUT_FORCE']
  livecheck = ENV['INPUT_LIVECHECK']

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token

  # Check inputs
  if livecheck.false?
    odie "Need 'formula' input specified" if formula.blank?
    odie "Need 'tag' input specified" if tag.blank?
  elsif tap.blank? && formula.blank?
    odie "Need 'tap' or 'formula' input specified"
  end

  # Get user details
  user = GitHub.open_api "#{GitHub::API_URL}/user"
  user_id = user['id']
  user_name = user['name'] || user['login']
  user_email = user['email'] || (
    # https://help.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address
    user_created_at = Date.parse user['created_at']
    plus_after_date = Date.parse '2017-07-18'
    need_plus_email = (user_created_at - plus_after_date).positive?
    user_email = "#{user_name}@users.noreply.github.com"
    user_email = "#{user_id}+#{user_email}" if need_plus_email
    user_email
  )

  # Tell git who you are
  git 'config', '--global', 'user.name', user_name
  git 'config', '--global', 'user.email', user_email

  # Update Homebrew
  brew 'update-reset'

  # Tap the tap if desired
  brew 'tap', tap unless tap.blank?
  
  # Define additional PR message
  message = '[`action-homebrew-bump-formula`](https://github.com/dawidd6/action-homebrew-bump-formula)'

  # Do the livecheck stuff or not
  if livecheck.false?
    # Change formula name to full name
    formula = tap + '/' + formula if !tap.blank? && !formula.blank?

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
         "--message=#{message}",
         *("--url=#{url}" unless is_git),
         *("--tag=#{tag}" if is_git),
         *("--revision=#{revision}" if is_git),
         *('--force' unless force.false?),
         formula
  else
    # Tap livecheck command
    brew 'tap', 'homebrew/livecheck'

    # Support multiple formulae in input
    formula = formula.split(/[ ,\n]/).reject(&:blank?) unless formula.blank?

    # Change formulae names to full names
    formula = formula.map { |f| tap + '/' + f } if !tap.blank? && !formula.blank?

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
      stable = Formula[formula].stable
      is_git = stable.downloader.is_a? GitDownloadStrategy

      # Prepare tag and revision or url
      if is_git
        dir = "/tmp/#{formula}"
        tag = stable.specs[:tag].gsub stable.version, info['version']['latest']
        git 'clone', '--depth', '1', '--branch', tag, stable.url, dir
        revision = read_git '-C', dir, 'rev-parse', 'HEAD'
      else
        url = stable.url.gsub stable.version, info['version']['latest']
      end

      begin
        # Finally bump the formula
        brew 'bump-formula-pr',
             '--no-audit',
             '--no-browse',
             "--message=#{message}",
             *("--url=#{url}" unless is_git),
             *("--tag=#{tag}" if is_git),
             *("--revision=#{revision}" if is_git),
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

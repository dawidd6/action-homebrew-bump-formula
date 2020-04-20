const exec = require('@actions/exec')

process.env.HOMEBREW_NO_ENV_FILTERING = "1"
process.env.HOMEBREW_NO_AUTO_UPDATE = "1"
process.env.HOMEBREW_NO_ANALYTICS = "1"
process.env.HOMEBREW_COLOR = "1"

exec.exec("brew", ["ruby", "main.rb"])
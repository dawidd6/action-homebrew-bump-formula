const exec = require('@actions/exec')
const path = require('path')

process.env.HOMEBREW_NO_ENV_FILTERING = "1"
process.env.HOMEBREW_NO_AUTO_UPDATE = "1"
process.env.HOMEBREW_NO_ANALYTICS = "1"
process.env.HOMEBREW_COLOR = "1"

exec.exec("brew", ["ruby", path.join(__dirname, "main.rb")])
    .catch(function (err) {
        console.log(err)
        process.exit(1)
    })
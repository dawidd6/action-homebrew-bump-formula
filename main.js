const exec = require('@actions/exec')
const path = require('path')

process.env.HOMEBREW_NO_ENV_FILTERING = "1"
process.env.HOMEBREW_NO_AUTO_UPDATE = "1"
process.env.HOMEBREW_NO_ANALYTICS = "1"
process.env.HOMEBREW_COLOR = "1"

console.log(__dirname)
console.log(__filename)
console.log(path.join(__dirname, "main.rb"))

exec.exec("brew", ["ruby", path.join(__dirname, "main.rb")])
    .catch(function () {
        process.exit(1)
    })
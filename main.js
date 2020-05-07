const exec = require('@actions/exec')
const core = require('@actions/core')
const path = require('path')

async function main() {
    try {
        process.env.HOMEBREW_NO_ENV_FILTERING = "1"
        process.env.HOMEBREW_NO_AUTO_UPDATE = "1"
        process.env.HOMEBREW_NO_ANALYTICS = "1"
        process.env.HOMEBREW_COLOR = "1"

        await exec.exec("brew", ["ruby", path.join(__dirname, "main.rb")])
    } catch (error) {
        core.setFailed(error.message)
    }
}

main()
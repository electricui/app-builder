"use strict"

const path = require("path")

function getPath() {
  if (process.env.USE_SYSTEM_APP_BUILDER === "true") {
    return "app-builder"
  }

  return path.join(__dirname, "bin", "app-builder.exe")
}

exports.appBuilderPath = getPath()
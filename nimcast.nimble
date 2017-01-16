# Package

version       = "0.1.0"
author        = "Konstantin Molchanov"
description   = "Site for the Nim Lang Podcast."
license       = "MIT"

srcDir = "src"

bin = @["nimcast"]

# Dependencies

requires "nim >= 0.16.0", "jester"

task setupDb, "Create a fresh database":
  exec "nimble c -r src/nimcast/setupDb.nim" 


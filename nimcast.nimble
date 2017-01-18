# Package

version       = "0.1.0"
author        = "Konstantin Molchanov"
description   = "Site for the Nim Lang Podcast."
license       = "MIT"

srcDir = "src"

bin = @["nimcast"]

requires "nim >= 0.16.0", "jester", "docopt"

task test, "Run tests":
  exec "nim c -r tests/test_db"

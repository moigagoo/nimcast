# Package

version       = "0.1.0"
author        = "Konstantin Molchanov"
description   = "Site for the Nim Lang Podcast."
license       = "MIT"

srcDir = "src"

bin = @["nimcast"]

# Dependencies

requires "nim >= 0.16.0", "jester"

task initDb, "Init database":
  exec "nimble c -r src/nimcastpkg/initDb.nim"

task test, "Run tests":
  exec "nimble c -r tests/test_db.nim"

task run, "Run nimcast":
  exec "nimble build"
  exec "./nimcast"

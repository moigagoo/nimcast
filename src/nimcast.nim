import strutils
import asyncdispatch
import jester
import nimcastpkg/views/home

routes:
  get "/":
    resp renderHome()

  get "/episode/latest":
    resp "Latest Episode"

  get "/episode/@number":
    cond @"number".isDigit
    resp "Episode #" & @"number"

  get "/episodes":
    resp "All Episodes"

runForever()

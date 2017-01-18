import strutils
import asyncdispatch
import jester
import nimcastpkg/views/home, nimcastpkg/db

let database = newDb()

routes:
  get "/":
    resp renderHome(database.getAllEpisodes())

  get "/episode/latest":
    redirect "/episode/" & $database.getLatestEpisode().id

  get "/episode/@number":
    cond @"number".isDigit
    resp "Episode " & @"number"

  get "/episodes/tag/@tag":
    resp "Episodes tagged with " & @"tag"

  get "/episodes/guest/@guest":
    resp "Episodes with " & @"guest"

runForever()

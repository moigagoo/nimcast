import strutils, times
import parseopt
import asyncdispatch, httpcore

import docopt
import jester

import nimcastpkg/db
import nimcastpkg/views/home, nimcastpkg/views/episode


let doc = """
Nimcast: The Nim Lang Podcast website.

Usage:
  nimcast site start [--db=<db>]
  nimcast db init [--db=<db>]
  nimcast db (add | new) [--db=<db>]
  nimcast db (list | ls) [--db=<db>]
  nimcast db (delete | del | rm) <episodeId> [--db=<db>]
  nimcast (-h | --help)

Options:
  -h --help   Show this screen.
  --db=<db>   Database file [default: nimcast.db]
"""

proc prompt(question: string, default: string = nil): string =
  var promptParts: seq[string] = @[question]

  if not default.isNil:
    promptParts.add "[default: '$#']" % default

  stdout.write promptParts.join(" ") & ": "

  let input = stdin.readline()

  if input.isNilOrEmpty:
    if not default.isNil:
      return default
    else:
      result = prompt(question, default)

  else:
    result = input

proc underline(line: string, character = '-'): string =
  [line, character.repeat(len(line)), ""].join("\n")

proc overline(line: string, character = '-'): string =
  [character.repeat(len(line)), line, ""].join("\n")

when isMainModule:
  let args = docopt(doc)

  if args["site"]:
    if args["start"]:
      let database = newDb($args["--db"])

      routes:
        get "/":
          resp renderHome(database.getAllEpisodes())

        get "/episode/latest":
          redirect "/episode/" & $database.getLatestEpisode().get().id

        get "/episode/@id":
          cond @"id".isDigit

          let episode = database.getEpisodeById(parseInt(@"id"))

          if episode.isNone:
            resp Http404, "There is no such episode :-("
          else:
            resp renderEpisode(episode.get())

        get "/episodes/tag/@tag":
          resp "Episodes tagged with " & @"tag"

        get "/episodes/guest/@guest":
          resp "Episodes with " & @"guest"

      runForever()

  elif args["db"]:
    if args["init"]:
      echo "Init Database".underline

      let database = newDb($args["--db"])
      database.init()
      database.close()

      echo "Database initialized."

    elif args["add"] or args["new"]:
      echo "Add Episode".underline

      let
        database = newDb($args["--db"])
        episode = newEpisode(
          title = prompt "Title",
          code = prompt "Code",
          tagline = prompt("Tagline", default = ""),
          guest = prompt("Guest", default = ""),
          timestamp = getTime(),
          notes = prompt("Notes (comma-separated)", default = "").split(','),
          tags = prompt("Tags (comma-separated)", default = "").split(',')
        )
        episodeId = database.add episode

      database.close()

      echo(("Episode $# added." % $episodeId).overline)

    elif args["list"] or args["ls"]:
      echo "Episodes".underline

      let database = newDb($args["--db"])

      for episode in database.getAllEpisodes():
        echo @[
          $episode.id, episode.title, episode.tagline,
          episode.timestamp.getLocalTime.format "d MMMM yyyy HH:mm"
        ].join(" | ")
      database.close()

    elif args["delete"] or args["del"] or args["rm"]:
      echo "Remove Episode".underline

      let
        database = newDb($args["--db"])
        episodeId = parseInt($args["<episodeId>"])

      database.remove episodeId
      database.close()

      echo(("Episode $# removed." % $episodeId).overline)

import strutils
import times
import parseopt

import db

proc prompt(question: string, default: string = nil): string =
  var promptParts: seq[string] = @[]

  promptParts.add question

  if not default.isNil:
    promptParts.add "(default: '$#')" % default

  stdout.write promptParts.join(" ") & ": "

  let input = stdin.readline()

  if input.isNilOrEmpty:
    if not default.isNil:
      return default
    else:
      result = prompt(question, default)

  else:
    result = input

proc frame(line: string): string =
  let
    row = "| $# |" % line
    border = '-'.repeat len(row)

  result = [border, row, border].join("\n")

when isMainModule:
  let database = newDb()

  for kind, key, value in getopt():
    if kind == cmdArgument:
      case key
      of "init":
        echo "Init Database".frame
        echo ""

        database.init()

        echo "Database initialized."

      of "add":
        echo "Add Episode".frame
        echo ""

        let
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

        echo ""
        echo "Episode $# added." % $episodeId

      of "list", "ls":
        echo "Episodes".frame
        echo ""

        for episode in database.getAllEpisodes():
          echo @[
            $episode.id, episode.title, episode.tagline,
            episode.timestamp.getLocalTime.format "d MMMM yyyy HH:mm"
          ].join(" | ")

      of "delete", "del", "rm":
        echo "Remove Episode".frame

        let episodeId = parseInt(prompt "Id")
        database.remove episodeId

        echo ""
        echo "Episode $# removed." % $episodeId

      else:
        discard

  database.close()

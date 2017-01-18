import times, strutils
import parseopt
import db_sqlite
import json
import future

type
  Episode* = object
    id*: int
    title*: string
    code*: string
    tagline*: string
    guest*: string
    timestamp*: Time
    notes*: seq[string]
    tags*: seq[string]

type
  Db* = ref object
    connection*: DbConn

proc newDb*(filename = "nimcast.db"): Db =
  new result
  result.connection = open(filename, "", "", "")

proc newEpisode*(title, code: string, tagline, guest: string = "",
                 timestamp: Time, notes, tags: seq[string] = @[]): Episode =
  Episode(title: title, code: code, tagline: tagline, guest: guest,
          timestamp: timestamp, notes: notes, tags: tags)

proc init*(db: Db) =
  db.connection.exec(
    sql"""
      CREATE TABLE Episode(
        id integer PRIMARY KEY AUTOINCREMENT,
        title text NOT NULL,
        code text NOT NULL,
        tagline text,
        guest text,
        timestamp integer NOT NULL,
        notes text,
        tags text
      );
    """
  )

proc close*(db: Db) = db.connection.close()

proc toEpisode(row: Row): Episode =
  result = Episode(
    id: parseInt(row[0]),
    title: row[1],
    code: row[2],
    tagline: row[3],
    guest: row[4],
    timestamp: row[5].parseInt().fromSeconds(),
    notes: lc[node.getStr() | (node <- parseJson(row[6])), string],
    tags: lc[node.getStr() | (node <- parseJson(row[7])), string],
  )

proc toEpisodes(rows: seq[Row]): seq[Episode] =
  lc[row.toEpisode | (row <- rows), Episode]

proc add*(db: Db, episode: Episode) =
  db.connection.exec(
    sql"INSERT INTO Episode VALUES (NULL, ?, ?, ?, ?, ?, ?, ?);",
    episode.title, episode.code, episode.tagline, episode.guest,
    int(episode.timestamp), %episode.notes, %episode.tags)

proc remove*(db: Db, episodeId: int) =
  db.connection.exec(
    sql"DELETE FROM Episode WHERE id = ?;", episodeId
  )

proc getLatestEpisode*(db: Db): Episode =
  let row = db.connection.getRow(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC LIMIT 1;"
  )
  result = row.toEpisode()

proc getEpisodesByGuest*(db: Db, guest: string): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode WHERE guest IS ? ORDER BY timestamp", guest)
    .toEpisodes()

proc getAllEpisodes*(db: Db): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC;").toEpisodes()

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

        database.add episode

        echo ""
        echo "Episode '$#' added." % episode.title

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

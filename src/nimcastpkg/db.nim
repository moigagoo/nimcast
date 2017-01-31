import times, strutils, sequtils
import db_sqlite
import json
import future

import options
export options


type
  Episode* = object
    id*: int
    title*: string
    code*: string
    guest*: string
    timestamp*: Time
    tagline*: seq[string]
    notes*: seq[string]
    tags*: seq[string]

type
  Db* = ref object
    connection*: DbConn

proc newDb*(filename = "nimcast.db"): Db =
  new result
  result.connection = open(filename, "", "", "")

proc newEpisode*(title, code: string, guest: string = "", timestamp: Time,
                 tagline, notes, tags: seq[string] = @[]): Episode =
  Episode(title: title, code: code, guest: guest, timestamp: timestamp,
          tagline: tagline, notes: notes, tags: tags)

proc `==`*(e1, e2: Episode): bool = e1.title == e2.title

proc init*(db: Db) =
  db.connection.exec(sql"DROP TABLE IF EXISTS Episode;")
  db.connection.exec(
    sql"""
      CREATE TABLE Episode(
        id integer PRIMARY KEY AUTOINCREMENT,
        title text NOT NULL,
        code text NOT NULL,
        guest text,
        timestamp integer NOT NULL,
        tagline text,
        notes text,
        tags text
      );
    """
  )

proc close*(db: Db) = db.connection.close()

proc toEpisode(row: Row): Option[Episode] =
  if row[0].isNilOrEmpty:
    none(Episode)
  else:
    some Episode(
      id: parseInt(row[0]),
      title: row[1],
      code: row[2],
      guest: row[3],
      timestamp: row[4].parseInt().fromSeconds(),
      tagline: lc[node.getStr() | (node <- parseJson(row[5])), string],
      notes: lc[node.getStr() | (node <- parseJson(row[6])), string],
      tags: lc[node.getStr() | (node <- parseJson(row[7])), string],
    )

proc toEpisodes(rows: seq[Row]): seq[Episode] =
  lc[row.toEpisode().get() | (row <- rows, row.toEpisode().isSome), Episode]

proc add*(db: Db, episode: Episode): int =
  db.connection.insertId(
    sql"INSERT INTO Episode VALUES (NULL, ?, ?, ?, ?, ?, ?, ?);",
    episode.title, episode.code, episode.guest, int(episode.timestamp),
    %episode.tagline, %episode.notes, %episode.tags
  ).int

proc remove*(db: Db, episodeId: int) =
  db.connection.exec(
    sql"DELETE FROM Episode WHERE id = ?;", episodeId
  )

proc getEpisodeById*(db: Db, episodeId: int): Option[Episode] =
  db.connection.getRow(
    sql"SELECT * FROM Episode WHERE id IS ?;",
    episodeId
  ).toEpisode()

proc getLatestEpisode*(db: Db): Option[Episode] =
  let row = db.connection.getRow(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC LIMIT 1;"
  )
  result = row.toEpisode()

proc getEpisodesByGuest*(db: Db, guest: string): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode WHERE guest IS ? ORDER BY timestamp DESC", guest
  ).toEpisodes()

proc getAllEpisodes*(db: Db): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC;").toEpisodes()

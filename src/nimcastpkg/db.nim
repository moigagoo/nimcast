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

proc `==`*(e1, e2: Episode): bool = e1.title == e2.title and
  e1.code == e2.code and e2.tagline == e2.tagline and e1.guest == e2.guest and
  e1.timestamp == e2.timestamp and e1.notes == e2.notes and e1.tags == e2.tags

proc init*(db: Db) =
  db.connection.exec(sql"DROP TABLE IF EXISTS Episode;")
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

proc toEpisode(row: Row): Option[Episode] =
  if row[0].isNilOrEmpty:
    none(Episode)
  else:
    some Episode(
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
  lc[row.toEpisode().get() | (row <- rows, row.toEpisode().isSome), Episode]

proc add*(db: Db, episode: Episode): int =
  db.connection.insertId(
    sql"INSERT INTO Episode VALUES (NULL, ?, ?, ?, ?, ?, ?, ?);",
    episode.title, episode.code, episode.tagline, episode.guest,
    int(episode.timestamp), %episode.notes, %episode.tags).int

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
    sql"SELECT * FROM Episode WHERE guest IS ? ORDER BY timestamp DESC", guest)
    .toEpisodes()

proc getAllEpisodes*(db: Db): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC;").toEpisodes()

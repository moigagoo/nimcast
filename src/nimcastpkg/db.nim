import times, strutils
import db_sqlite
import json
import future

type
  Episode* = object
    title*: string
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

proc newEpisode*(title: string, tagline, guest: string = "", timestamp: Time,
                 notes, tags: seq[string] = @[]): Episode =
  Episode(title: title, tagline: tagline, guest: guest, timestamp: timestamp,
          notes: notes, tags: tags)

proc init*(db: Db) =
  db.connection.exec(
    sql"""
      CREATE TABLE IF NOT EXISTS Episode(
        title text PRIMARY KEY,
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
    title: row[0],
    tagline: row[1],
    guest: row[2],
    timestamp: row[3].parseInt().fromSeconds(),
    notes: lc[node.getStr() | (node <- parseJson(row[4])), string],
    tags: lc[node.getStr() | (node <- parseJson(row[5])), string],
  )

proc toEpisodes(rows: seq[Row]): seq[Episode] =
  lc[row.toEpisode | (row <- rows), Episode]

proc add*(db: Db, episode: Episode) =
  db.connection.exec(
    sql"INSERT INTO Episode VALUES (?, ?, ?, ?, ?, ?);",
    episode.title, episode.tagline, episode.guest,
    int(episode.timestamp), %episode.notes, %episode.tags)

proc getLatestEpisode*(db: Db): Episode =
  let row = db.connection.getRow(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC LIMIT 1;"
  )

  result = row.toEpisode()

proc getEpisodesByGuest*(db: Db, guest: string): seq[Episode] =
  db.connection.getAllRows(
    sql"SELECT * FROM Episode WHERE guest IS ? ORDER BY timestamp",
    guest
  ).toEpisodes()

proc getAllEpisodes*(db: Db): seq[Episode] =
  db.connection.getAllRows(sql"SELECT * FROM Episode;").toEpisodes()

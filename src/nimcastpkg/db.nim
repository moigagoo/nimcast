import times
import db_sqlite
import json

type
  Episode* = object
    title*: string
    tagline*: string
    guest*: string
    timestamp*: Time
    notes*: seq[string]
    tags*: seq[string]

type
  Db = ref object
    connection: DbConn

proc newDb*(filename = "nimcast.db"): Db =
  new result
  result.connection = open(filename, "", "", "")

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
      );""")

proc close*(db: Db) = db.connection.close()

proc add*(db: Db, episode: Episode) =
  db.connection.exec(
    sql"INSERT INTO Episode VALUES (?, ?, ?, ?, ?, ?);",
    episode.title, episode.tagline, episode.guest,
    int(episode.timestamp), %episode.notes, %episode.tags)

proc findLatestEpisode*(db: Db): Episode =
  new result

  let row = db.connection.getRow(
    sql"SELECT * FROM Episode ORDER BY timestamp DESC LIMIT 1;")

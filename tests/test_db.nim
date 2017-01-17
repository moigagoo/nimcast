import unittest
import os, times
import nimcastpkg/db

suite "database tests":
  const testDbFilename = "nimcast_test.db"
  let testDb = newDb(testDbFilename)
  testDb.init()

  test "add episode":
    testDb.add Episode(
      title: "Test Episode",
      tagline: "This is a test episode.",
      guest: "Guest McGuestface",
      timestamp: getTime(),
      notes: @["http://mcguestface.com"],
      tags: @["test", "episode", "guest"]
    )

  testDb.close()
  removeFile testDbFilename

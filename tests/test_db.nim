import unittest
import os, times
import nimcastpkg/db

suite "database tests":
  const testDbFilename = "nimcast_test.db"
  removeFile testDbFilename
  let testDb = newDb(testDbFilename)
  testDb.init()

  test "add episode with all fields":
    let testEpisode = newEpisode(
      title = "Test Episode",
      tagline = "This is a test episode.",
      guest = "Guest McGuestface",
      timestamp = getTime() - 5.minutes,
      notes = @["http://mcguestface.com"],
      tags = @["test", "episode", "guest"]
    )

    testDb.add testEpisode

    check:
      testEpisode in testDb.getAllEpisodes()

  test "add episode only with mandatory fields":
    let testMinimalEpisode = newEpisode(
      title = "Minimal Episode",
      timestamp = getTime() - 5.minutes
    )

    testDb.add testMinimalEpisode

    check:
      testMinimalEpisode in testDb.getAllEpisodes()

  test "get latest episode":
    let testLatestEpisode = newEpisode(
      title = "New Episode",
      timestamp = getTime()
    )

    testDb.add testLatestEpisode

    check:
      testDb.getLatestEpisode() == testLatestEpisode

  test "get episodes by guest":
    const guest = "Guest"

    let
      testGuestEpisode1 = newEpisode(
        title = "Episode with Guest 1",
        guest = guest,
        timestamp = getTime() - 10.minutes
      )
      testGuestEpisode2 = newEpisode(
        title = "Episode with Guest 2",
        guest = guest,
        timestamp = getTime() - 5.minutes
      )

    testDb.add testGuestEpisode1
    testDb.add testGuestEpisode2

    check:
      testDb.getEpisodesByGuest(guest) == @[testGuestEpisode1,
                                            testGuestEpisode2]

  testDb.close()
  removeFile testDbFilename

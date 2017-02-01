import unittest
import os, times
import nimcastpkg/db

suite "database tests":
  const testDbFilename = "nimcast_test.db"
  removeFile testDbFilename
  let testDb = newDb(testDbFilename)
  testDb.init()

  setup:
    testDb.init()

  tearDown:
    testDb.init()

  test "add episode with all fields":
    let testEpisode = newEpisode(
      title = "Test Episode",
      code = """<iframe width="100%" height="146" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/303284599&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe>""",
      guest = "Guest McGuestface",
      timestamp = getTime() - 5.minutes,
      tagline = @["This is a test episode."],
      notes = @["http://mcguestface.com"],
      tags = @["test", "episode", "guest"]
    )

    discard testDb.add testEpisode

    check:
      testEpisode in testDb.getAllEpisodes()

  test "add episode only with mandatory fields":
    let testMinimalEpisode = newEpisode(
      title = "Minimal Episode",
      code = """<iframe width="100%" height="146" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/303284599&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe""",
      timestamp = getTime() - 5.minutes
    )

    discard testDb.add testMinimalEpisode

    check:
      testMinimalEpisode in testDb.getAllEpisodes()

  test "get latest episode":
    let testLatestEpisode = newEpisode(
      title = "New Episode",
      code = """<iframe width="100%" height="146" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/303284599&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe""",
      timestamp = getTime()
    )

    discard testDb.add testLatestEpisode

    check:
      testDb.getLatestEpisode().get() == testLatestEpisode

  test "get episodes by guest":
    const guest = "Guest"

    let
      testGuestEpisode1 = newEpisode(
        title = "Episode with Guest 1",
        code = """<iframe width="100%" height="146" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/303284599&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe""",
        guest = guest,
        timestamp = getTime() - 10.minutes
      )
      testGuestEpisode2 = newEpisode(
        title = "Episode with Guest 2",
        code = """<iframe width="100%" height="146" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/303284599&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe""",
        guest = guest,
        timestamp = getTime() - 5.minutes
      )

    discard testDb.add testGuestEpisode1
    discard testDb.add testGuestEpisode2

    check:
      testDb.getEpisodesByGuest(guest) == @[testGuestEpisode2,
                                            testGuestEpisode1]

  test "remove episode":
    let
      testEpisodeToRemove = newEpisode(
        title = "Episode to Be Removed",
        code = "Doesn't matter, will be removed.",
        timestamp = getTime()
      )
      testEpisodeToRemoveId = testDb.add testEpisodeToRemove

    testDb.remove testEpisodeToRemoveId

    check:
      testDb.getEpisodeById(testEpisodeToRemoveId).isNone

  testDb.close()
  removeFile testDbFilename

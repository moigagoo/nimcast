import asyncdispatch
import jester
import nimcastpkg/views/index

routes:
  get "/":
    resp renderIndex()

runForever()

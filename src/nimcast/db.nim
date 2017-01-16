import times

type
  Episode* = object
    topic*: string
    tagline*: string
    guest*: string
    timestamp*: Time
    notes*: seq[string]
    tags*: seq[string]

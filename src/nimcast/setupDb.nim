import db_sqlite

stdout.write "Creating database... "

var db = open("nimcast.db", "", "", "")

db.exec(sql"""
  CREATE TABLE IF NOT EXISTS Episode(
    topic text PRIMARY KEY,
    tagline text NOT NULL,
    guest text,
    timestamp integer NOT NULL,
    notes text,
    tags text
  );
""")

echo "Done!"

db.close()

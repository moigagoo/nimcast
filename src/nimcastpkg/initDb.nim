import db

stdout.write "Creating new database... "

var database = newDb()
database.init()
database.close()

echo "Done!"
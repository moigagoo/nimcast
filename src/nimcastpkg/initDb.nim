import db

stdout.write "Creating database... "
var database = newDb()
database.init()
database.close()
echo "Done!"
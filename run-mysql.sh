# Create database and import schema
mysql -u root -e "CREATE DATABASE $DATABASE_NAME;"
mysql -u root -D $DATABASE_NAME < schema.sql
mysql -u root -D $DATABASE_NAME < data.sql

# Create user
mysql -u root -e "CREATE USER '$MYSQL_USER'@localhost IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION"

# Make our changes take effect
mysql -u root -e "FLUSH PRIVILEGES;"

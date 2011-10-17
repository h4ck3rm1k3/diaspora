require 'pg'

#  adapter: postgresql
#  host: localhost
#  port: 5432
#  username: postgres
#  password:
#  encoding: unicode

#config = config.symbolize_keys
host     = "localhost"
#port     = config[:port] || 5432
username = "postgres"

conn = PGconn.open(:dbname => 'diaspora_development')



res = conn.exec('SELECT 1 AS a, 2 AS b, NULL AS c')
print res.getvalue(0,0) # '1'

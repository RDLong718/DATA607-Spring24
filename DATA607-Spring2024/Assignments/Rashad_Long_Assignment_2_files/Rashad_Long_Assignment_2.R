# Load information from SQL database into an R dataframe

# Parameters
user <- 'rashad.long66'
password <- 'M@Goo007!'
database <- 'rashad.long66'
host <- 'cunydata607sql.mysql.database.azure.com'
port <- 3306

# Connect to the database
connection <- DBI::dbConnect(drv = MariaDB(), 
                             dbname = database,
                             host = host, 
                             port = port, 
                             user = user, 
                             password = password)

# Fetch results
tbl(connection, "ratings") %>% 
  collect() -> data
#Disconnect from the database
DBI::dbDisconnect(connection)

# Preview
data







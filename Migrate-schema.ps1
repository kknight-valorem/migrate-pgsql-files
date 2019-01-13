<# Migrate-Schema.ps1

.Synopsis
Create SQL file with the code for postgres schema and imports it.

.Description
    pg_dump - will export schema
    psql    - will import it

    EXPORTING
        From Azure tutorial on DMS for Postgres migration use the following command to export
        pg_dump -o -h localhost -U postgres -d db_name -s > your_schema.sql
                -o = --oids  	include OIDs in dump
                -h = --host  	host name of database server
                -U = --username	dbadmin username
                -d = --dbname	name of database (can be a connection string)
                -s = --schema-only 
                >  = --file	output filename
        The exported SQL file usess ALTER TABLE to <owner> which is why the user 
        needs to exist in the target.

    IMPORTING
        Using psql to import into Azure has a sytax challenge in that the at sign "@" is both 
        in the username as well as the seperator between password and server dns address.
        To sovle this use the connection string minus the username and pass the username 
        as a prarameter prior to the dbname conneciton string.  Thankfully the psql parser
        loads this appropriately and forms a valid connection. 

.Additional Info
    Git-Hub location of files - https://github.com/kknight-valorem/migrate-pgsql-files.git
    Tutorial: Migrate PostgreSQL to Azure using DMS
        https://docs.microsoft.com/en-us/azure/dms/tutorial-postgresql-azure-postgresql-online
    Build a Ruby and Postgres app in Azure App Service on Linux
        https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-ruby-postgres-app

.Parameter azpguser
Param( [string]$azpguser ) - Azure database for PostgreSQL username.
This may be found on the Azure resource overview blade in the format user@server

.Parameter azpgsql
Param( [string]$azpgsql ) - This is the Fully Qualified Domain Name (FQDN) 
This may be found on the Azure resource overview blade in the format <servername>.postgres.database.azure.com

.Example
.\Migrate-schema.ps1 "postgres@pgsql95rg951771" "pgsql95rg951771.postgres.database.azure.com"

.Example
.\Migrate-schema.ps1 –azpguser "postgres@pgsql95rg951771" -azpgsql "pgsql95rg951771.postgres.database.azure.com"

################################################################################
#>
Param( [string] $azpguser,
       [string] $azpgsql )
<#
$azpguser = "<replace with user name>"
$azpgsql  = "<replace with azure name>"
#>

$password = "Passw0rd0000"
$database = "sampledb"
$psql     = "C:\Program Files\PostgreSQL\9\bin\psql.exe"
$pg_dump  = "C:\Program Files\PostgreSQL\9\bin\pg_dump.exe"

# export
Write-output "Exporting $database schema"
& "$pg_dump" --oids --schema-only --file="$database.sql"  --dbname="postgresql://postgres:$password@localhost:5432/$database"

Write-output ""

#import - needs same user(role) "postgres" provisioned beforehand in target to work as the generated sql will 
#exectue Alter Table on the resultant table based on the source owner
#
#dbname can be just the dbname or a connection string, this code is using the connection string

Write-output "Loading $database schema"
$dbname = "postgresql://:" + $password + "@" + $azpgsql + ":5432/$database"
& "$psql" --username="$azpguser" --dbname="$dbname" --file="$database.sql"

write-output "Schema migrated."
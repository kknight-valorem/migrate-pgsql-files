# Create-Load.ps1 - create load on the postgres database
# Author: Ken Knight
<#
    This is a simple PowerShell script that generates load on a PostgresSQL database. 
    It was tested against verion 9.5 of enterprisedb.com's PostgreSQL running locally.
    I'm putting this up on GitHub because it took me a while to research this syntax
    and I'm hoping to save you some time.

How it works
    It works by using the commandline tool for PostgreSQL called "psql.exe". 
    To invoke and craft the invocation of the image in PowerShell I had to use the & operator. 
    The next trick was getting the connection string to work with the password since there is 
    no explicit way to pass the password for PSQL.exe (example: PSQL --password=password).
    Turns out the -dbname parameter supports a connection string format with password.
    The prohibts PSQL from prompting for password every time and allows the script to run.
    Lastly my example is for a table named "t1", with two coloumns "c1" int primary key and "c2" text

    One last trick - if you are trying to use PSQL against an Azure database which has an "@" 
    in the user name (ex: postgresadmin@azuredb4postgres) drop the username from the dbname 
    and pass it explicitly 
        psql --username postgresadmin@azuredb4postgres --dbname="postgresql://:Password@localhost:5432/postgres"

Syntax
    For the dbname fqdn = fully qualified domain name (location of the server)
    --dbname "postgresql://username:password@fqdn:port/database"

Postgress SQL clean-up 
    DELETE FROM tasks WHERE (id > 100);
    select * from tasks;
#>

Write-Output " "
Write-Output " "
Write-Output "Welcome to the PostgreSQL sample load generator"
Write-Output "***********************************************"

$psql = "C:\Program Files\PostgreSQL\9\bin\psql.exe"
$dbname = "postgresql://postgres:Passw0rd0000@localhost:5432/sampledb"
$table = "tasks"
$wait  = 20;
Write-Output "Working against connection $dbname table $table"
Write-Output " "

Write-Output "Cleaning up records if any from prior runs."
& "$psql" --dbname=$dbname --command  "DELETE FROM $table WHERE (id > 100);"

$i=100;
Write-Output " "
Write-Output "Generating load starting from $i every $wait seconds against $dbname"
DO {
    $i=$i+1;
    Write-output "PSQL INSERT INTO $table VALUES ($i, 'Task $i');"
    $time = (get-date).ToString('u');
    & "$psql" --dbname=$dbname --command "INSERT INTO $table VALUES ($i, 'Task $i', '$time', '$time');"
    Start-Sleep -Seconds $wait;
} While ($true);

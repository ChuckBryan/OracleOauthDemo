param(
    [Parameter(Position = 0)]
    [string]$SqlCommand
)

if ([string]::IsNullOrEmpty($SqlCommand)) {
    # Just connect to SQLPlus
    docker exec -it oracle-db sqlplus OAUTH_DEMO_USER/DemoPassword123@FREEPDB1
}
else {
    # Execute the SQL command
    docker exec -it oracle-db sqlplus -S OAUTH_DEMO_USER/DemoPassword123@FREEPDB1 "@$SqlCommand"
}
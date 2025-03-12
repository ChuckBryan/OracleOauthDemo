# Define the container name
$containerName = "oracle-db"

# Define the path to the create_wallet.sh script inside the container
$scriptPathInContainer = "/etc/ora_wallet/scripts/create_wallet.sh"

# Run the bash script inside the container using Docker exec
docker exec -it $containerName bash $scriptPathInContainer
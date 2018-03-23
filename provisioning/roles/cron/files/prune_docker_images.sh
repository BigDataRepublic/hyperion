#!/bin/bash

if [ $USER != "root" ]
then
    echo "Script should be running as user root"
    exit 1
fi

if [[ `docker version --format '{{.Server.Version}}'` == "17.03"* ]]
then
    echo "Your Docker version does not support filtering. You need Docker 17.06 or higher."
    exit 1
fi

# Define date before which everything is removed
DELETE_UNTIL="30d"

echo "Pruning unused Docker images"
docker image prune --all --force --filter "until=$DELETE_UNTIL" --filter "label!=keep"

echo "Pruning unused Docker networks"
docker network prune --force --filter "until=$DELETE_UNTIL" --filter "label!=keep"

echo "Pruning unused containers"
docker container prune --force --filter "until=$DELETE_UNTIL" --filter "label!=keep"

echo "Pruning unused volumes"
docker volume prune --force  --filter "until=$DELETE_UNTIL" --filter "label!=keep"

echo "Done!"
exit 0

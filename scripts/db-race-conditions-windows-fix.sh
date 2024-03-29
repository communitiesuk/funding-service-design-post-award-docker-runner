#!/bin/bash

docker compose up -d database
container_id=$(docker ps --format "{{.ID}}" --filter "name=database")
sleep 1
docker exec "$container_id" psql -U postgres -c "CREATE DATABASE data_store;"
docker exec "$container_id" psql -U postgres -c "CREATE DATABASE data_store_test;"
docker exec "$container_id" psql -U postgres -c "CREATE DATABASE account_store;"

if [[ $* == *--build* ]]
  then
    docker compose up --build
else
  docker compose up
fi

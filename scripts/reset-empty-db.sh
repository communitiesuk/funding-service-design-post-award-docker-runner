#!/bin/bash

## DESTROYS EXISTING DB AND STARTS A NEW EMPTY ONE

# stop and remove all containers and volumes associated with the database
original_container_id=$(docker ps --format "{{.ID}}" --filter "name=database")
docker stop "$original_container_id"
docker rm -v "$original_container_id"

# start a new database container
docker compose up -d database
new_container_id=$(docker ps --format "{{.ID}}" --filter "name=database")
sleep 3

# create tables in new database
docker exec -ti "$new_container_id" psql -U postgres -c "CREATE DATABASE data_store;"
docker exec -ti "$new_container_id" psql -U postgres -c "CREATE DATABASE account_store;"
docker exec -ti "$new_container_id" psql -U postgres -c "CREATE DATABASE fund_store;"
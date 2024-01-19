#!/bin/bash

export VSC_DEBUG='python -m debugpy --listen 0.0.0.0:5678 -m flask run --no-debugger --no-reload -p 8080 -h 0.0.0.0'

if [[ $* == *--build* ]]
  then
    docker compose up --build
else
  docker compose up
fi
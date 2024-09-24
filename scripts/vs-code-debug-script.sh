#!/bin/bash

export VSC_DEBUG='python -m debugpy --listen 0.0.0.0:5678 -m flask run --no-debugger --no-reload -p 4001 -h 0.0.0.0 --cert=/app-certs/cert.pem --key=/app-certs/cert-key.pem'

if [[ $* == *--build* ]]
  then
    docker compose up --build
else
  docker compose up
fi

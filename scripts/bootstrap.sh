#!/bin/bash

echo "Cloning required repositories ..."

for repo in $(cat docker-compose.yml | grep 'context: ../' | cut -d':' -f2 | xargs -n1 basename); do
  if ! [ -d "../${repo}" ]; then
    echo "Cloning ${repo} ..."
    git clone git@github.com:communitiesuk/${repo} ../${repo}
  else
    echo "Skipping ${repo} which already exists."
  fi
done

echo "Done."

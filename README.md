# funding-service-design-post-award-docker-runner

## Prerequisites
*  [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
*  All funding-service-design apps (listed as `context` keys in [docker-compose.yml](docker-compose.yml) must be checked out in the parent directory on this repository

## How to run
* Copy `.env.example` to `.env` and ask another team member for the missing secret value
* `docker compose up`
* Apps should be running on localhost on the ports in the [docker-compose.yml](docker-compose.yml) `ports` key before the `:`
* Note: When testing locally using the docker runner, docker might use the cached version of fsd_utils (or any another depedency). To avoid this and pick up your intended changes, run `docker compose build <service_name> --no-cache` first before running `docker compose up`.

## Troubleshooting
* Check you have the `main` branch and latest revision of each repo checked out
* If dependencies have changed you may need to rebuild the docker images using `docker compose build`
* To run an individual app rather than all of them, run `docker compose up appname` where app name is the key defined under `services` in [docker-compose.yml](docker-compose.yml) 
* If you get an error about a database not existing, try running `docker compose down` followed by `docker compose up` this will remove and re-create any existing containers and volumes allowing the new databases to be created.
  * Or you can use [this script](#db-race-conditions-windows-fixsh)

## localstack setup
* The localstack S3 buckets should be running at http://data-store-file-assets-dev.s3.localhost.localstack.cloud:4566/ and http://data-store-failed-files-dev.s3.localhost.localstack.cloud:4566/

# Scripts
## reset-all-repos
Shell script to go through each repo in turn, checkout the `main` branch and execute `git pull`. This is useful when you want to run the docker runner with the latest of all apps. Also optionally 'resets' the postgres image by forcefully removing it - useful if your local migrations get out of sync with the code or you need to start with a blank DB.

    ./scripts/reset-all-repos.sh -wm /path/to/workspace/dir

Where
- w: if supplied, will wipe the postgres image
- m: if supplied, will reset all repos to main
- path/to/workspace/dir: absolute path to your local directory where all the repos are checked out. Expects them all named the same as the git repos, eg. `funding-service-design-post-award-data-store`.

## db-race-conditions-windows-fix.sh
Shell script that starts the postres container first, creates two tables (`account_store` and `fund_store`) needed
for authenticator, and then boots the rest of the containers. On windows run from Git Bash.

    ./scripts/db-race-conditions-windows-fix.sh (optional: --build)


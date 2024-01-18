# funding-service-design-post-award-docker-runner

## Prerequisites
*  [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
*  **All** funding-service-design apps (listed as `context` keys in [docker-compose.yml](docker-compose.yml) must be cloned and checked out in the parent directory of this repository

## How to run
* Copy `.env.example` to `.env` and ask another team member for the missing secret values
* `docker compose up`
* Apps should be running on localhost on the ports in the [docker-compose.yml](docker-compose.yml) `ports` key before the `:`
* Note: When testing locally using the docker runner, docker might use the cached version of fsd_utils (or any another dependency). To avoid this and pick up your intended changes, run `docker compose build <service_name> --no-cache` first before running `docker compose up`.

## Troubleshooting
* Check you have the `main` branch and latest revision of each repo checked out
* If dependencies have changed you may need to rebuild the docker images using `docker compose build`
* To run an individual app rather than all of them, run `docker compose up appname` where app name is the key defined under `services` in [docker-compose.yml](docker-compose.yml) 
* If you get an error about a database not existing, try running `docker compose down` followed by `docker compose up` this will remove and re-create any existing containers and volumes allowing the new databases to be created.
  * Or you can use [this script](#db-race-conditions-windows-fixsh)

## localstack setup
* The localstack S3 bucket should be running at http://data-store-failed-files-dev.s3.localhost.localstack.cloud:4566/

# Scripts
## reset-all-repos
Shell script to go through each repo in turn, checkout the `main` branch and execute `git pull`. This is useful when you want to run the docker runner with the latest of all apps. Also optionally 'resets' the postgres image by forcefully removing it - useful if your local migrations get out of sync with the code or you need to start with a blank DB.

    ./scripts/reset-all-repos.sh -wm /path/to/workspace/dir

Where
- w: if supplied, will wipe the postgres image
- m: if supplied, will reset all repos to main
- path/to/workspace/dir: absolute path to your local directory where all the repos are checked out. Expects them all named the same as the git repos, eg. `funding-service-design-post-award-data-store`.

## db-race-conditions-windows-fix.sh
Shell script that starts the postgres container first, creates two databases (`account_store` and `fund_store`) needed
for authenticator, and then boots the rest of the containers. On windows run from Git Bash.

    ./scripts/db-race-conditions-windows-fix.sh (optional: --build)

# Running in debug mode (VS Code)
## Python Apps
The containers in the docker runner can be run with python in debug mode to allow a debugger to connect. This gives instructions for connecting VS Code.

### Docker

There is currently a separate docker-compose file to allow the VS Code debugger to work with the code executing in the docker runner.

Each app in [docker-compose.debug.yml](docker-compose.debug.yml) includes the following value for `command`, which makes the debugger run:

        command: bash -c "python -m debugpy --listen 0.0.0.0:5678 -m flask run --no-debugger --host 0.0.0.0 --port 8080"

The 'no-debugger' part relates to the flask debugger, it's useful to remove this option if you want to see the stack traces for things like jinja template errors. The *submit* and *frontend* app commands also include 'no-reload' which disables the Flask auto-reload. This is needed for the VS Code debugging to work for these apps, but can be removed along with the `python -m debugpy --listen 0.0.0.0:5678 -m` if you'd rather use the Flask debugger and reinstate the auto-reload.

To then expose the debug port 5678 to allow a debugger interface to connect, each app also has a (unique) port mapping, eg.:

        ports:
                - 5683:5678

The individual *data-store* and *frontend* app dockerfiles are currently used in production so shouldn't be hardcoded to point to requirements-dev.txt (which installs debugpy) instead of requirements.txt. Instead, you can rebuild these services and pass in a buildarg which will use requirements-dev.txt to build the services to include debugpy:

    docker compose build --build-arg REQUIREMENTS="requirements-dev.txt"

To start the services with the debug docker-compose file so the VS Code debugger can be attached, run the following command:

    docker compose -f docker-compose.debug.yml up

### VS Code

The port mapping allows you to then configure your chosen debugger (in this case VS code) to connect on that port. If not already present, add the following to the `configurations` block in the launch.json (if not already present) for the particular app you want to debug, where port matches the one exposes in docker-compose. These configurations should be named after the service, `Docker Runner <service-name>` eg. Docker Runner frontend.


        {
            "name": "Docker runner",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5683
            },
            "pathMappings": [
                {
                    "localRoot": "${workspaceFolder}",
                    "remoteRoot": "."
                }
            ],
            "justMyCode": true
        }

Save your launch.json, navigate to the debug view and select this new configuration from the drop down, then click the green triangle button to connect the debugger. Add some breakpoints and you should be able to step through the code executing in the docker runner.
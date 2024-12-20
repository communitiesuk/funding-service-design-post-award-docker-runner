# Archival notice

This docker runner has been replaced by a single combined Funding Service docker runner here: https://github.com/communitiesuk/funding-service-design-post-award-docker-runner

# funding-service-design-post-award-docker-runner

## Prerequisites
* [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
* Update your `/etc/hosts` file to include the following lookups:
  * `127.0.0.1  submit-monitoring-data.levellingup.gov.localhost`
  * `127.0.0.1  find-monitoring-data.levellingup.gov.localhost`
  * `127.0.0.1 authenticator.levellingup.gov.localhost`
  * `127.0.0.1 account-store.levellingup.gov.localhost`
  * `127.0.0.1 localstack`
* Install [mkcert](https://github.com/FiloSottile/mkcert).
  * On MacOS, `brew install mkcert` should suffice.

## How to run
* Run `make bootstrap` to clone all required repositories (they will be cloned to the parent directory of this repository).
* Run `make certs` to install a root certificate authority and generate appropriate certificates for our localhost domains.
  * If you are on a MHCLG laptop, your default user is unlikely to have `sudo` permission, which is required, so you may need to take the following steps instead:
    * Find your STANDARD_USER (that you use normally) and ADMIN_USER (that can use `sudo`) account names. Substitute appropriately in the following commands:
    * `su - <ADMIN_USER>`
    * `cd` to the directory *above* this docker-runner repo.
    * run `sudo chown -R <ADMIN_USER>:staff funding-service-design-post-award-docker-runner`
    * `cd funding-service-design-post-award-docker-runner`
    * `make certs`  # Read the output - should be no apparent errors.
    * `cd ..`
    * `sudo chown -R <STANDARD_USER>:staff funding-service-design-post-award-docker-runner`
    * `exit` to return to your standard user shell.
* `make up` (this basically just runs docker compose up, but if you have generated certs it will inject these automatically)
* Apps should be running on localhost on the ports in the [docker-compose.yml](docker-compose.yml) `ports` key before the `:`
* Note: When testing locally using the docker runner, docker might use the cached version of fsd_utils (or any another dependency). To avoid this and pick up your intended changes, run `docker compose build <service_name> --no-cache` first before running `docker compose up`.

## Troubleshooting
* Check you have the `main` branch and latest revision of each repo checked out
* If dependencies have changed you may need to rebuild the docker images using `docker compose build`
* To run an individual app rather than all of them, run `docker compose up appname` where app name is the key defined under `services` in [docker-compose.yml](docker-compose.yml) 
* If you get an error about a database not existing, try running `docker compose down` followed by `docker compose up` this will remove and re-create any existing containers and volumes allowing the new databases to be created.
  * Or you can use [this script](#db-race-conditions-windows-fixsh)

## localstack setup
* The localstack S3 buckets should be running at http://data-store-failed-files-dev.s3.localhost.localstack.cloud:4566/ , http://data-store-successful-files-dev.s3.localhost.localstack.cloud:4566/ and
* http://data-store-find-data.s3.localhost.localstack.cloud:4566/

## Azure AD and Notify setup (Optional)

### Azure AD
We have an override locally so you can access protected routes without authenticating, but if you need to test something specific to authentication it is possible to set this up:
* For Azure AD authentication to work locally, you will need a user account on the Test Active Directory, ask a tech lead how to request this
* Copy `.env.example` to `.env` and ask a tech lead for the missing secret values to set in `.env`
* Uncomment the `AZURE_AD_CLIENT_ID`, `AZURE_AD_CLIENT_SECRET` and `AZURE_AD_TENANT_ID` lines from [`docker-compose.yml`](docker-compose.yml)
* Disable `DEBUG_USER_ON` in the development config of `funding-service-design-post-award-data-frontend` and `funding-service-design-post-award-submit` repositories

### Notify
We have an override locally so that Notify emails are not sent by default. If you need to something specific to Notify integration it is possible to set this up:
* Copy `.env.example` to `.env`, ask a tech lead for value for `NOTIFY_API_KEY` and set it in `.env`

# Scripts

## bootstrap.sh
Clones all required repositories.
## reset-all-repos
Shell script to go through each repo in turn, checkout the `main` branch and execute `git pull`. This is useful when you want to run the docker runner with the latest of all apps. Also optionally 'resets' the postgres image by forcefully removing it - useful if your local migrations get out of sync with the code or you need to start with a blank DB.

    ./scripts/reset-all-repos.sh -wm /path/to/workspace/dir

Where
- w: if supplied, will wipe the postgres image
- m: if supplied, will reset all repos to main
- path/to/workspace/dir: absolute path to your local directory where all the repos are checked out. Expects them all named the same as the git repos, eg. `funding-service-design-post-award-data-store`.

## db-race-conditions-windows-fix.sh
Shell script that starts the postgres container first, creates two databases (`account_store` and `data_store`) needed
for authenticator, and then boots the rest of the containers. On windows run from Git Bash.

    ./scripts/db-race-conditions-windows-fix.sh (optional: --build)

## vs-code-debug-script.sh
Shell script to allow the VS Code debugger to attach to the running containers. See section below for full instructions.

# Running in debug mode (VS Code)
## Python Apps
The containers in the docker runner can be run with python in debug mode to allow a debugger to connect. This gives instructions for connecting VS Code.

### Docker

To allow the VS Code debugger to work with the code executing in the docker runner, you can run the [vs-code-debug-script.sh](./scripts/vs-code-debug-script.sh) to pass a variable to the docker-compose file which will allow the debugger to run. 

    export VSC_DEBUG='python -m debugpy --listen 0.0.0.0:5678 -m flask run --no-debugger --no-reload -p 8080 -h 0.0.0.0'

The `VSC_DEBUG` variable modifies the docker-compose value for `command` to allow the debugger to run. The 'no-debugger' part relates to the flask debugger, it's useful to remove this option if you want to see the stack traces for things like jinja template errors. The 'no-reload' part disables the Flask auto-reload. This is currently needed for the VS Code debugging to work specifically for the *submit* and *frontend* apps, but can be removed along with the `python -m debugpy --listen 0.0.0.0:5678 -m` if you'd rather use the Flask debugger and reinstate the auto-reload.

The [docker-compose.yml](docker-compose.yml) then exposes the debug port 5678 to allow a debugger interface to connect, each app also has a (unique) port mapping, eg.:

    ports:
            - 5683:5678

The individual *data-store* and *frontend* app dockerfiles are currently used in production so shouldn't be hardcoded to point to requirements-dev.txt (which installs debugpy) instead of requirements.txt. Instead, we pass in a buildarg which will use requirements-dev.txt to build the services to include debugpy. This buildarg is set in the [docker-compose.yml](docker-compose.yml) file.

    build:
      context: ../funding-service-design-post-award-data-store
      args: 
        REQUIREMENTS: requirements-dev.txt

To start the services so the VS Code debugger can be attached, run the following script. If running for the first time, add the optional `--build` to rebuild *data-store* and *frontend* using requirements-dev.txt which will install debugpy. If running the script without `--biuld` and of these containers exits with the error 'No module named debugpy' then rerun the script with the optional `--build`.):

    ./scripts/vs-code-debug-script.sh (optional: --build)

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

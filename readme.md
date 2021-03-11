# EMAP-bot

This is a template docker arrangement for developing, and then running a machine learning pipeline on a regular schedule. In the UCLH EMAP environment, this means that we can build connect to the live EMAP database ('star'), wrangle and analyse the data, and then return the results back to a table in the User Data Store (UDS). This in turn can then feed a dashboard, or be made available to the Electronic Health Record itself in near real time.

The example pipeline is uses R, but this could be switched to Python by modifying the docker image.

Alongside this, we also we also provide a working development environment comprised of Rstudio Server (from the [rocker project](https://hub.docker.com/r/rocker/tidyverse) and [pgweb](https://sosedoff.github.io/pgweb/) as a database front end for PostgreSQL. Since both of these run in a browser (Chrome/Firefox recommended) then the entire system is available without any further installation.

Please use `make` to interact with the project.

## Install

```sh
git clone https://github.com/docsteveharris/try-ofelia.git
git checkout master
```

You now must generate your 'dot' files. Examples are provided as `env-example` and `renviron-example`. Edit these and provide HTTP proxies, user names and passwords. Save them as `.env` and `.Renviron` respectively. These must be ignored by `.gitignore` so they remain out of version control and your secrets don't leak.

Now you can build your images which will pick up the secrets above, and therefore be ready to connect.


```sh
make dev-build
make dev-up
```

Now go enter the IP address of your GAE in a modern browser (Chrome/Firefox), and login. The default user for Rstudio is *rstudio* and the default password is *sitrep*.

e.g.
* http://172.16.149.155:8790/ for RStudio
* http://172.16.149.155:8791/ for pgweb

## Develop your application


### Notes on the RStudio dev environment

* Installing additional libraries: The RStudio image is able to install from CRAN and from GitHub. It comes pre-installed with ODBC and the necessary drivers to connect to PostgreSQL and Microsoft SQL Server. Everything the user might need will need to be installed from within RStudio. 
* The `.Renviron` file holds all the 'secrets' (usernames, passwords etc.) and _must_ be in .gitignore







TODO: tie together the R libraries between the dev arm and the app

When you look inside the project, there 


This is a template docker arrangement for running a specific R script on a schedule. 

You need to git clone this to the GAE or your local machine.
It will try and pick up the any local proxies (`http_proxy` etc.).
You must make your own `.env` file from the example `env-example` file.
Then 

```
docker-compose up --build
```

What it should do

* Every 5 mins it will read the last entry from the IDS; if that is not within the last 300 seconds it will raise an alert and 'stop'
* The job result (success/failure) will be posted to the slack channel.

Features

* Creates a docker image using Rocker/tidyverse
* Sets-up ODBC infrastructure for connection to MS-SQL databases (e.g. Epic's Clarity or Caboodle)
* Installs CRAN and GitHub packages (e.g. [emapR](https://github.com/inform-health-informatics/emapR.git))
* Builds and installs local packages (to make parts of the code more transportable)
* Runs `monitor_ids.R` every 5 minutes which could contain any bit of code you wish
* Adjust the schedule as per the instructions [here](https://github.com/mcuadros/ofelia)
* Pushes a status message to slack

It should be relatively trivial to swap this out for a Python version.

Links and references

* [Setting up ofelia](https://github.com/viktorsapozhok/docker-python-ofelia)
* [Building a slack webhook](https://api.slack.com/messaging/webhooks)

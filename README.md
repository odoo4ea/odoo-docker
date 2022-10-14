# Introduction

Multistage and source code install with a smaller image size, based on the official Docker image for Odoo.

We tried to be as close as possible with odoo/docker but there are some diferences from oficial image:

* Source code downloaded from github as zip file
* These images are not tagging the commit or date. We should just build and tag with the date or hash
* Only one volume for the data folder (filestore and sessions)
* Enterprise and custom will be part of the image. /mnt/ee-addons and /mnt/extra-addons
* There is a docker-compose.yml file for easier testing

The full readme is generated over Odoo Docker Docs, specifically in [docker-library/docs/odoo](https://github.com/docker-library/docs/tree/master/odoo).
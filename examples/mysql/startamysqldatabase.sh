#!/usr/bin/env bash
# Use the command docker exec -it <container id> bash - to log into your server and play around
# mysql -u root -p
# create database PGR301;
# use PGR301
# see create_table_example.sh for how to create a table

docker run --name mysql-dev -e MYSQL_ROOT_PASSWORD=topsecret -d mysql
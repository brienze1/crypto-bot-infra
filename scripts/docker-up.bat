#!/bin/bash

docker-compose -p crypto-bot -f ../build/docker-compose.yml down --volumes

docker-compose -p crypto-bot -f ../build/docker-compose.yml build --no-cache

docker-compose -p crypto-bot -f ../build/docker-compose.yml up
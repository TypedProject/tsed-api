###############################################################################
###############################################################################
##                      _______ _____ ______ _____                           ##
##                     |__   __/ ____|  ____|  __ \                          ##
##                        | | | (___ | |__  | |  | |                         ##
##                        | |  \___ \|  __| | |  | |                         ##
##                        | |  ____) | |____| |__| |                         ##
##                        |_| |_____/|______|_____/                          ##
##                                                                           ##
## description     : Dockerfile for TsED Application                         ##
## author          : TsED team                                               ##
## date            : 20210108                                                ##
## version         : 1.0                                                     ##
###############################################################################
###############################################################################
ARG NODE_VERSION=14.16.0
FROM node:${NODE_VERSION}-alpine as builder

WORKDIR /src

RUN apk update

COPY package.json .
COPY yarn.lock .
COPY lerna.json .
COPY processes.config.js .

RUN apk update && apk add build-base git python

COPY ./packages/backoffice/package.json ./packages/backoffice/package.json
COPY ./packages/server/package.json ./packages/server/package.json

RUN yarn install --production --frozen-lockfile --ignore-scripts

FROM node:${NODE_VERSION}-alpine
WORKDIR /
COPY --from=builder /src .

COPY ./packages/backoffice/build ./packages/backoffice/build
COPY ./packages/server ./packages/server

EXPOSE 8083
ENV PORT 8083

CMD ["yarn", "start:prod"]

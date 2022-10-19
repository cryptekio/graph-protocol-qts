# Graph Protocol Query Testing Service
The purpose of this app is to be used as a stress-testing tool for The Graph Gateway and any indexers behind it. It consumes qlog queries from the hosted graph service and can replay them on-demand. It is fully configurable and controlled via API calls.

## Setting up

The app consists of the following components:
 - The main web API for receiving requests
 - Async workers for replaying queries
 - PostgreSQL databases for storing queries
 - Redis db for managing the worker queues

We provide a sample Dockerfile and a docker-compose template that can be used for deploying the app. To start, clone the repo, and cd into the directory.

One should first set up the environment variables either through the `.env` file or by exporting them directly. Following variables are supported:

```
GRAPH_GATEWAY_API_KEY="GATEWAY_KEY_HERE"
GRAPH_GATEWAY_URL="https://gateway.testnet.thegraph.com"
AWS_ACCESS_KEY_ID="ACCESS_KEY_HERE"
AWS_SECRET_ACCESS_KEY="SECRET_KEY_HERE"
AWS_S3_ENDPOINT="https://gateway.storjshare.io"
AWS_S3_BUCKET="gnosis-chain"
AWS_S3_MAX_CHUNK_SIZE=16
RAILS_MAX_THREADS=20
TMP_DIR="/tmp/imports"
AWS_REGION="us-west-2"
REDIS_URL="redis://redis"
POSTGRES_HOST=postgres
POSTGRES_USER=rails
POSTGRES_PASSWORD="POSTGRES_PASSWORD_HERE"
```

Once env variables have been set up, you can run docker compose:

`# docker compose up --build`

This will build out the necessary docker images and start the containers. However, we still need to initialize the database, so press CTRL+C to get back into the terminal and run the following:

`# docker compose run web rake db:reset`
`# docker compose run web rake db:migrate`

If those succeed, the database connection works and the schema has been set up, so we can run the application now:

`# docker compose up`

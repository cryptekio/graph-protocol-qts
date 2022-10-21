# Environment variables

You can configure environment variables in individual containers in the docker-compose.yml file, or simply store your vars in an `.env` file in the repo and these will get picked up by the app when it boots. Following variables are required in order for the app to function properly:

```sh
GRAPH_GATEWAY_API_KEY="MY_API_KEY" # API key needed to send queries to the gateway
GRAPH_GATEWAY_URL="https://gateway.testnet.thegraph.com" # The Graph Gateway URL
AWS_ACCESS_KEY_ID="MY_S3_ACCESS_KEY" # ACCESS_KEY_ID for accessing the S3 bucket that stores the qlog query datasets
AWS_SECRET_ACCESS_KEY="MY_S3_SECRET_KEY" # SECRET_KEY for accessing the S3 bucket that stores the qlog query datasets
AWS_S3_BUCKET="S3_BUCKET_NAME" # Named of the bucket where the datasets are stored
AWS_S3_ENDPOINT="https://gateway.storjshare.io" # S3 endpoint in case you are not using the standard S3 service from AWS
AWS_REGION="us-west-2" # AWS region. keep this as it is even if you are not using AWS S3
TMP_DIR="/tmp/imports" # Temporary directory for storing datasets when downloading from S3. Do not change without updating the docker-compose file
REDIS_URL="redis://redis" # Redis URL. Change this if you are not using the docker-compose.yml redis, otherwise leave it as it is.
POSTGRES_HOST=postgres # PostgresSQL host. Change this if you are using a standalone postgres setup
POSTGRES_USER=rails # PostgresSQL user. Change this if you are using a standalone postgres setup
POSTGRES_PASSWORD=EDGk5vCM9b57 # PostgresSQL password. Change this if you are using a standalone postgres setup
RAILS_MAX_THREADS=20 # Tweaks the maximum number of threads that rails can use. Can be increased in case of higher loads, but 20 is usually fine.
```

# Graph Protocol Query Testing Service

The aim of this application is to provide a way to stress-test The Graph gateway and any indexers behind it. It functions by consuming historical qlog query data (currently provided from the hosted graph service), and replays them ondemand against the selected gateway. It is an intependent service that can be controlled via API calls.

## System Requirements

System requirements will vary depending on the load you are putting on the app. Based on the qlog datasets we received from the team during development (2-4GB in size, unpacked), we recommend the following optimal specs:

- At least 4 vCPUs (cores) for proper multithreading support
- At least 16 GB of RAM memory
- Relatively fast disks (nvme preferred) with enough disk space to store all the datasets you intended to load + enough disk space to be used as temporary space when downloading datasets from S3
- Preferably at least 1 gbit uplink

As a reference, during development we've used a machine with the following specs:

- 2x Micron 5200 SSDs in RAID1,
- Intel Core i7-4770 CPU
- 32 GB of ram
- 1gbit uplink with unlimited bandwidth

**Note: While the app is fully capable of running standalone, the reference implementation assumes you will be running it in Docker, using the provided docker-compose.yml file. **

## Getting started

1. To start, clone the repo and cd into the directory:

```sh
git clone git@github.com:cryptekio/graph-protocol-qts.git
cd graph-protocol-qts
```

2. Build the necessary docker containers:

```sh
docker compose build
```

3. You will likely want to configure some environment variables before proceeding, see [Variables](docs/variables.md) for more information.

4. Run database migrations to prepare postgresql for writing:

```sh
docker compose run web rake db:reset
docker compose run web rake db:migrate
```

5. Finally, start the application 

```sh
docker compose up
```

## Controlling the app
Refer to the [API reference document](docs/api.md) on how to manage the app, upload datasets, start tests, etc.

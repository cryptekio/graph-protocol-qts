# API reference

## Structure

By default, the app listens on `localhost:3000` and provides two main endpoints for controling behavior:

- `localhost:3000/querysets` is used for querying the current available qlog query datasets, creating new ones (by importing them from S3) and deleting unneded ones.
- `localhost:3000/tests` is used for creating load test definitions and starting/stoping tests.


## Importing datasets

Datasets should be stored in an S3 bucket that is accessible to the app via credentials supplied in the environment variables. Imports will start automatically as soon as you create a queryset definition:

```sh
curl -s -X POST -H "Content-Type: application/json" -d '{"name":"MyQuerySet", "description":"This is a fancy new query set", "file_path": "gnosis.20220901.20220909.txt.gz"}' http://127.0.0.1:3000/querysets | json_pp
```
where `file_path` refers to the key of the dataset in S3 you want to import. 

**Note: App expects that all datasets are in a gzipped format**

If your request is successful, you should get a response that includes a unique id for the query set. You can use the id to check the status of the query set (ie is it still being imported):

```sh
curl -s -X GET http://127.0.0.1:3000/querysets/dfdec5b7-5238-4293-bc30-f7668f932763 | json_pp
```
Where `dfdec5b7-5238-4293-bc30-f7668f932763` refers to the ID of the query set received in the previous request. The response will look like:

```json
{
   "description" : "This is a fancy new query set",
   "file_path" : "gnosis.20220901.20220909.txt.gz",
   "id" : "dfdec5b7-5238-4293-bc30-f7668f932763",
   "name" : "MyQuerySet",
   "status" : "importing"
}
```

The `status: importing` means that the dataset is still being downloaded from s3 and imported into postgresql. Once it becomes `ready` you can use the dataset to run your load tests.

You can also get a list of all available datasets by querying the root endpoint:

```sh
curl -s -X GET http://127.0.0.1:3000/querysets | json_pp
```

## Running tests
First you want to create your test definition, by referencing a query set previously imported and some optional data:

```sh
curl -s -X POST -H "Content-Type: application/json" -d '{"query_set_id": "dfdec5b7-5238-4293-bc30-f7668f932763"}' http://127.0.0.1:3000/tests
```

Available addtional arguments:
- `subgraphs: []` Array of subgraphs deployment IDs you may want to select from the dataset. This will filter out the dataset so the only queries being sent from it are for that particular subgraph list. By default all subgraphs are included
- `query_limit: 1000` Limits the number of queries to send from the particular dataset. Default is everything. 

**Note: unlike queryset imports, tests need to be started manually after creating their definition**

Response will contain a test id which you may use to run your test:

```sh
curl -s -X POST http://127.0.0.1:3000/tests/0b727e78-7409-4d20-a9a0-ddc6d37b64d8/run | json_pp
```

Executing a test will trigger a background job to run the test and create a test "instance" definition within which you can check the status of the test:

```sh
curl -s -X GET http://127.0.0.1:3000/tests/0b727e78-7409-4d20-a9a0-ddc6d37b64d8 | json_pp
```

will result in:

```json
{
   "chunk_size" : 1000,
   "id" : "0b727e78-7409-4d20-a9a0-ddc6d37b64d8",
   "instances" : [
      {
         "728fbde1-c0b4-44c3-b20c-0720fc41aa1b" : "finished"
      }
   ],
   "query_set_id" : "dfdec5b7-5238-4293-bc30-f7668f932763",
   "sleep_enabled" : true,
   "subgraphs" : []
}
```

At any time you can stop a particular test instance by issuing a stop request:

```sh
curl -s -X POST http://127.0.0.1:3000/tests/0b727e78-7409-4d20-a9a0-ddc6d37b64d8/instance/728fbde1-c0b4-44c3-b20c-0720fc41aa1b/stop | json_pp
```

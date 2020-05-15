# wysiblocks-production

## Export DB and strapi public data from dev

### DB

Make sure full dev container stack is up and running. To make sure it does and double check by running

```
$ doccker ps
```

Attach to mongodb container, dump the entire datapase into a folder inside the container and copy it to the host

```
$ docker exec -it wysiblocks_mongodb bash

# mongodump --out /mongo_dump --username user_stories --password user_stories_root

$ docker cp wysiblocks_mongodb:/mongo_dump .

```

Copy public assets strapi folder to the host

1. Option 1. Simply copy the folder from a running container
   ```
   $ docker cp wysiblocks_strapi_cms:/app/public .
   ```
2. Options 2. Copy and archive the named docker volume, stored inside host's docker VM

   ```
   docker run --rm -it -v %cd%\strapi_public_backup:/backup -v /var/lib/docker/volumes:/volumes alpine:edge tar cfz backup/data.tgz volumes/wysiblocks_strapi_public/
   ```

## import DB and strapi public data to production

Make sure the dev stack is stopped, if your are in your local environment (doesn't apply to remote server). To ensure run

```
$ docker-compose -f docker-compose.dev.yml down
```

Start db-only production stack, copy mongodb dump into the production container, attach to it and run mongorestore and stop the stack

```
$ docker-compose -f docker-compose.db-only.yml up -d

$ docker cp mongo_dump wysiblocks_mongodb:/

$ docker exec -it wysiblocks_mongodb bash

# mongorestore mongo_dump/ --username user_stories --password user_stories_root

$ docker-compose -f docker-compose.db-only.yml down
```

Start the full stack and copy Strapi's public folder into it's container

```
$ docker-compose -f docker-compose.full-stack.yml up -d

$ docker cp public wysiblocks_strapi_cms:/app/
```

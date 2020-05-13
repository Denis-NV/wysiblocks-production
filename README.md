# wysiblocks-production

```
docker run --rm -it -v %cd%\strapi_public_backup:/backup -v /var/lib/docker/volumes:/volumes alpine:edge tar cfz backup/data.tgz volumes/wysiblocks_strapi_public/
```

```
$ docker exec -it wysiblocks_mongodb bash

# mongodump --out /mongo_dump --username user_stories --password user_stories_root

$ docker cp wysiblocks_mongodb:/mongo_dump .


$ docker cp mongo_dump wysiblocks_mongodb:/

# mongorestore mongo_dump/ --username user_stories --password user_stories_root
```

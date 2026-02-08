1. Disabled Tutor Default Internal Databases
tutor config save --set RUN_MYSQL=false \
                  --set RUN_MONGODB=false \
                  --set RUN_REDIS=false \
                  --set RUN_ELASTICSEARCH=false

2. Initialzing Amazon Manged RDS
tutor config save --set MYSQL_HOST=openedx.czeggmy8a2oc.us-east-2.rds.amazonaws.com \
                  --set MYSQL_USERNAME=admin \
                  --set MYSQL_PASSWORD='removedforsecurity' \
                  --set MYSQL_DATABASE=openedx

tutor config save --set MYSQL_ROOT_USERNAME=admin
tutor config save --set MYSQL_ROOT_PASSWORD='removedforsecurity'

3. Initialzing Amazon Manged DocumentDB
tutor config save --set MONGODB_HOST=openedx-mongo.cluster-czeggmy8a2oc.us-east-2.docdb.amazonaws.com \
                  --set MONGODB_PORT=27017 \
                  --set MONGODB_USERNAME=openedx \
                  --set MONGODB_PASSWORD='removedforsecurity'

4. Initialzing Amazon Manged ElasticCache
tutor config save --set REDIS_HOST=openedx-redis.mqtg7r.ng.0001.use2.cache.amazonaws.com \
                  --set REDIS_PORT=6379

5. Initialzing Amazon Manged OpenSearch
tutor config save --set ELASTICSEARCH_HOST=vpc-openedx-search-dsnbdqwlmc2ctk5sdjlruh7b5a.us-east-2.es.amazonaws.com \
                  --set ELASTICSEARCH_PORT=443 \
                  --set ELASTICSEARCH_SCHEME=https \
                  --set ELASTICSEARCH_AUTH_USER=Openedx1! \
                  --set ELASTICSEARCH_AUTH_PASSWORD=removedforsecurity

tutor k8s launch
    

TAG=chrono2002/mongo_s3:4.4.6-bionic

docker build -t $TAG .
docker push $TAG

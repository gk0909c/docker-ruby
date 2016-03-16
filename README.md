# docker-ruby #
ruby container.

## usage ##
To run,
```
docker run -it --name ruby gk0909c/eclim bash
```

persistent volume,
```
docker volume create --name ruby-workspace
docker run -it -v ruby-workspace:/home/dev/workspace --name ruby gk0909c/ruby bash
```

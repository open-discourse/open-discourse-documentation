`docker build -t open-discourse/r .`

`docker run --rm -p 8787:8787 -e PASSWORD="password" open-discourse/r`

To delete all containers including its volumes use,

`docker rm -vf $(docker ps -a -q)`

To delete all the images,

`docker rmi -f $(docker images -a -q)`

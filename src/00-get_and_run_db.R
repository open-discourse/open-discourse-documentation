# login with access token -------------------------------------------------
system(
  "cat ./src/access_token.txt | docker login https://docker.pkg.github.com -u FloLimebit --password-stdin"
)

# pull latest docker image of database ------------------------------------
system(
  "docker pull docker.pkg.github.com/open-discourse/open-discourse/database:latest"
)

# run database ------------------------------------------------------------
system(
  "docker run --name 'OD' --env POSTGRES_USER=postgres --env POSTGRES_DB=postgres --env POSTGRES_PASSWORD=postgres  -p 5432:5432 -d docker.pkg.github.com/open-discourse/open-discourse/database"
)

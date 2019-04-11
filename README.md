This Dockerfile clones the mapbender-starter git repository and builds
a debian 9 container with mapbender up and running.

To get started:

Do once:

* `git clone git@github.com:mapbender/docker.git mapbender`
* `cd mapbender`
* `docker-compose build`

To start:

* `docker-compose up`
* `call http://localhost:9000 or http://localhost:9000/app.php in your browser`

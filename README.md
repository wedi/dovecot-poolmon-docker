# poolmon health monitoring for dovecot director backends

This container wraps [poolmon](https://github.com/brandond/poolmon) from Brandon Davidson to run alongside Dovecot director, e.g. as a sidecar in a Kubernetes pod.

Dovecot directors don't do backend health checking on their own. Instead, they timeout and fail if the request's target is unavailable. The [Dovecot wiki](https://wiki2.dovecot.org/Director#Health_monitoring_of_backend_servers) points to poolmon which seems to be the most common way to go if you want to avoid a full load balancer setup.

Tags align with poolmon releases: `0.6`, `latest`  
Please open an issue or pull request [on github](https://github.com/wedi/dovecot-poolmon-docker) if there is a new release I haven't noticed.


## Configuration

For detail about the usage of poolmon, check out the [help online](https://github.com/brandond/poolmon/blob/master/poolmon#L92) or run `docker run weised/dovecot-poolmon --help`.

Use the following environment variables to configure the poolmon running inside this container.

| Name               | Default                                               |
| ------------------ | ----------------------------------------------------- |
| DEBUG              | ``                                                    |
| DIRECTOR_SOCKET    | `/var/run/dovecot/director-admin`                     |
| INTERVAL           | `30`                                                  |
| LOGFILE            | `/dev/stdout`                                         |
| PORTS              | `--port=110 --port=143 --ssl=993 --ssl=995 --port=24` |
| TIMEOUT            | `10`                                                  |
| ADDITIONAL_OPTIONS | ``                                                    |

I chose to export only those options I deem common (aka those I am tweaking 🤓) but you can append any parameters to the `ADDITIONAL_OPTIONS` variable, e.g. `ADDITIONAL_OPTIONS=--lockfile=/my/very/own/lockfile.pid`.

Enable poolmon's debug log by setting `DEBUG` to a non-empty value.

The parameters `--foreground` and `--logfile=/dev/stdout` are always set and cannot be overwritten.


## Running

* Mount your director's socket to `/var/run/dovecot/director-admin` (or any custom location you set using the `DIRECTOR_SOCKET` environment variable).
* Set above environment variables to your desired values.
* Set `ADDITIONAL_OPTIONS` to add additional parameters to poolmon.

### Commandline

Start a container:  
`docker run -e INTERVAL=5 -v /var/run/dovecot/director-admin:/var/run/dovecot/director-admin weised/dovecot-poolmon`

Runing the container like an executable might come handy in some situations:  

* `docker run -v /var/run/dovecot/director-admin:/var/run/dovecot/director-admin weised/dovecot-poolmon --timeout 5 --port IMAP:123`
* `docker run weised/dovecot-poolmon --help`

**Note:** If you set any command line parameters, environment variables will be ignored.

### docker-compose.yml

```YAML
dovecot-poolmon:
  image: weised/dovecot-poolmon:latest
  restart: "always"
  environment:
    # Overwrite interval, check every ten years
    - POOLMON_INTERVAL=315360000
    # Add a port to check without overwriting the default ones
    - POOLMON_ADDITIONAL_OPTIONS=--port=POP3:4711
  volumes:
    - /var/run/dovecot/director-admin:/var/run/dovecot/director-admin
```

## Building

You can easily build the container yourself:

```sh
git clone https://github.com/wedi/dovecot-poolmon-docker.git
cd dovecot-poolmon-docker
docker build -t dovecot-poolmon .
```

Optionally, choose the version of poolmon:  
`docker build --build-arg POOLMON_VERSION=master -t dovecot-poolmon .`


## License

Copyright © 2019 Dirk Weise <code-at-dirk-weise.de>  
Released under the terms of the [MIT License](https://opensource.org/licenses/MIT).

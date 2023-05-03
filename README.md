# Nikto inside docker +dropbear

nikto inside dropbear

included:
- nikto
- dropbear
- scp

## WHY?

After much thought, how to securly separate nikto from main docker process,
we have some options:

1. use docker.sock inside parent process, not recommended to give that kind of privilege
2. use something like kestra, and make a http trigger, its nice good, but currently free version of kestra doesnt handle authentication, not a choice to left it open
3. use ssh server inside a worker (nikto)

> ssh server is not really a best practice inside a container. But, its more secure rather than 2 others options.


### SSH_PUB_KEY

SSH_PUB_KEY is special environment variable to set a single public key for authorized_keys.
hint: you can actually put it inside docker-compose `environment`


#### concept

1. ssh into this nikto server
2. run `~/nikto-scan.sh "http://host.docker.internal:8089" /tmp/out.json`
3. scp /tmp/out.json

> nikto-scan will return exit code 16 if there is an ongoing process. only 1 scan at a time (lock file)

#### example run 1:

```sh
  docker run --rm -e SSH_PUB_KEY="`cat ~/.ssh/id_rsa.pub`" -p 22:22 ryanhs/nikto-dropbear:latest
```

on client side: (nikto docker on port 2201)

```sh
  ssh -p 2201 nikto@localhost

  # without verification, just because its localhost, or you can map volume host key
  ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 2201 nikto@localhost
  
  # on ssh to scan with nikto
  ./nikto-scan.sh http://host.docker.internal:8089 $PWD/adminer.json 1m

  # on ssh to analyze nikto result
  cat adminer.json | jq ".vulnerabilities[].OSVDB" | sort -u

  # exit ssh, then copy from server
  scp result.json nikto@localhost:/home/nikto/result.json
```
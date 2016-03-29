# alpinebootstrap

## Why?

Layers, and be able to create a new container fast.

## How?

Alpine linux use `apk` for package management.

We leverage on this to create a `chroot` and optionally create a docker image.

## Requirements

- Linux
- Docker if using `-d` option

## Demo time

### go1.5

```bash
root@nuc:~# time alpinebootstrap.sh -d -c -p alpine-go15 go
-d was triggered, docker container will be created
-c was triggered, community repo will be enabled
Additional packages to be installed:
go

root@nuc:~# docker run --rm -i alpine-go15 go version
go version go1.5.3 linux/amd64
root@nuc:~# 

root@nuc:~# docker images alpine-go15
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
alpine-go15         latest              4ca8a461be9b        4 seconds ago       179.5 MB
root@nuc:~# 
```

### go1.6

```bash
root@nuc:~# time alpinebootstrap.sh -d -c -e -p alpine-go16 go                                                                                                                                                                                
-d was triggered, docker container will be created
-c was triggered, community repo will be enabled
-e was triggered, edge version will be used
version overriden to edge
Additional packages to be installed:
go

root@nuc:~# docker run --rm -i alpine-go16 go version
go version go1.6 linux/amd64
root@nuc:~# 

root@nuc:~# docker images alpine-go16
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
alpine-go16         latest              26d9a2d01bad        6 seconds ago       192.5 MB
root@nuc:~# 
```


## Options

`[-c]`		 enable community repo.

`[-d]`		 create docker image, will use `path` name for container.

`[-e]`		 enable edge version. Default is `latest-release`, ie stable one.

`[-h]`		 help.

`[-t]`		 enable testing repo. It will override to edge version.

` -p <path>`	 chroot to be used. This will be created on current directory, and reused for next run. 

`-v [<version>]` to override the version. Defaults to `latest-release`, this are Alpine linux optiones ie. edge, latest-release, 3.3, 3.2, etc.

`[<package>]`	 list of packages to be installed, this are alpine package names.


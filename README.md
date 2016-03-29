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

root@nuc:~# docker history alpine-go15
IMAGE               CREATED             CREATED BY          SIZE                COMMENT
4ca8a461be9b        9 minutes ago                           179.5 MB            Imported from -
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

root@nuc:~# docker history alpine-go16
IMAGE               CREATED             CREATED BY          SIZE                COMMENT
26d9a2d01bad        10 minutes ago                          192.5 MB            Imported from -

```

## vs `golang:latest`


```bash
root@nuc:~# docker images golang
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
golang              latest              2529f72145a7        4 days ago          743.9 MB

root@nuc:~# docker run golang:latest go version
go version go1.6 linux/amd64

root@nuc:~# docker history golang:latest
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
2529f72145a7        4 days ago          /bin/sh -c #(nop) COPY file:7e87b0ea22c04c4eb   2.481 kB            
<missing>           4 days ago          /bin/sh -c #(nop) WORKDIR /go                   0 B                 
<missing>           4 days ago          /bin/sh -c mkdir -p "$GOPATH/src" "$GOPATH/bi   0 B                 
<missing>           4 days ago          /bin/sh -c #(nop) ENV PATH=/go/bin:/usr/local   0 B                 
<missing>           4 days ago          /bin/sh -c #(nop) ENV GOPATH=/go                0 B                 
<missing>           4 days ago          /bin/sh -c curl -fsSL "$GOLANG_DOWNLOAD_URL"    318 MB              
<missing>           4 days ago          /bin/sh -c #(nop) ENV GOLANG_DOWNLOAD_SHA256=   0 B                 
<missing>           4 days ago          /bin/sh -c #(nop) ENV GOLANG_DOWNLOAD_URL=htt   0 B                 
<missing>           4 days ago          /bin/sh -c #(nop) ENV GOLANG_VERSION=1.6        0 B                 
<missing>           4 days ago          /bin/sh -c apt-get update && apt-get install    134 MB              
<missing>           5 days ago          /bin/sh -c apt-get update && apt-get install    122.6 MB            
<missing>           3 weeks ago         /bin/sh -c apt-get update && apt-get install    44.29 MB            
<missing>           3 weeks ago         /bin/sh -c #(nop) CMD ["/bin/bash"]             0 B                 
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:b5391cb13172fb513d   125.1 MB            
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


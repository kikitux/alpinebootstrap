#!/bin/bash
# 20160328
# Alvaro Miranda
# kikitux@gmail.com 

#check we have the few tools we need
TOOLS="chroot grep tar wget"
which ${TOOLS} &>/dev/null
if [ $? -ne 0 ]; then
    echo "ensure the followin tools are available \'${TOOLS}\'"
fi

#check we are on Linux
if [ "`uname -s`" != "Linux" ]; then
    echo "this script is to be run in linux"
    exit 1
fi

usage(){
        echo "ie alpinebootstrap.sh [-c] [-d] [-e] [-h] [-t] -p <path> -v [<version>] [<package>..<package>]"
}

unset MIRROR mirror
MIRROR[0]=http://dl-cdn.alpinelinux.org/alpine
MIRROR[1]=http://dl-1.alpinelinux.org/alpine
MIRROR[2]=http://dl-2.alpinelinux.org/alpine
MIRROR[3]=http://dl-3.alpinelinux.org/alpine
MIRROR[4]=http://dl-4.alpinelinux.org/alpine
MIRROR[5]=http://dl-5.alpinelinux.org/alpine

mirror="${MIRROR[0]}" # we start with cdn and will check other if issues
ARCH=x86_64
VERSION=latest-stable
APK_TOOL=apk-tools-static-2.6.5-r1.apk

# Root has ${UID} 0
ROOT_UID=0   
if [ "${UID}" != "${ROOT_UID}" ] 
then
    echo "You are not root. Please use su to become root."
    exit 0
fi

while getopts ":cdehtp:v:" opt; do
  case $opt in
    c)
      echo "-c was triggered, community repo will be enabled" >&2
      COMMUNITY="yes"
      ;;
    d)
      echo "-d was triggered, docker container will be created" >&2
      DOCKER="yes"
      ;;  
    p)
      echo "-p was triggered, path: $OPTARG" >&2
      CHROOT=$OPTARG
      ;;
    v)
      echo "-v was triggered, version: $OPTARG" >&2
      VERSION=$OPTARG
      ;;  
    h)
      usage
      exit
      ;;  
    e)
      echo "-e was triggered, edge version will be used" >&2
      VERSION=edge
      ;;

    t)
      echo "-t was triggered, testing repo will be enabled" >&2
      TESTING=yes
      VERSION=edge
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ ! "${CHROOT}" ]; then
    usage
    exit 1
fi

if [ ${VERSION} == "edge" ]; then
    APK_TOOL=apk-tools-static-2.6.6-r1.apk
    echo "version overriden to ${VERSION}"
fi
    
shift $((OPTIND-1))

set_resolv(){
  grep nameserver ${CHROOT}/etc/resolv.conf &>/dev/null
  if [ $? -ne 0 ]; then
      > ${CHROOT}/etc/resolv.conf
      echo "nameserver 8.8.8.8" >> ${CHROOT}/etc/resolv.conf
      echo "nameserver 8.8.4.4" >> ${CHROOT}/etc/resolv.conf
  fi
}

PACKAGES="${@}"

if [ "${PACKAGES}" ];then
    echo "Additional packages to be installed:"
    echo "${PACKAGES}"
fi

if [ -f ${CHROOT}/sbin/apk ]; then

  set_resolv
  echo "${mirror}/${VERSION}/main" >  ${CHROOT}/etc/apk/repositories
  [ -z "${COMMUNITY}" ] || ( echo "${mirror}/${VERSION}/community" | tee -a ${CHROOT}/etc/apk/repositories)
  [ -z "${TESTING}" ] || ( echo "${mirror}/${VERSION}/testing" | tee -a ${CHROOT}/etc/apk/repositories)

  chroot ${CHROOT} /sbin/apk --no-cache update
  chroot ${CHROOT} /sbin/apk --no-cache upgrade

  if [ "${PACKAGES}" ]; then
      chroot ${CHROOT} /sbin/apk --no-cache add ${PACKAGES}
  fi

else

  i="0"
  while [ ! -f ${APK_TOOL} ]; do
      [ $i -eq ${#MIRROR[@]} ] && break
      wget ${mirror}/${VERSION}/main/${ARCH}/${APK_TOOL}
      [ $? -ne 0 ] && mirror="${MIRROR[RANDOM%${#MIRROR[@]}]}"
      i=$[$i+1]
  done

  mkdir -p ${CHROOT}{/sbin/,/root,/etc/apk,/proc}
  tar -xzf ${APK_TOOL} -C ${CHROOT}/ sbin/apk.static

  echo "${mirror}/${VERSION}/main" >  ${CHROOT}/etc/apk/repositories
    
  if [ ${COMMUNITY} ] ; then
     echo "${mirror}/${VERSION}/community" >> ${CHROOT}/etc/apk/repositories
  fi
  
  if [ ${TESTING} ] ; then
     echo "${mirror}/${VERSION}/testing" >> ${CHROOT}/etc/apk/repositories
  fi
  
  ${CHROOT}/sbin/apk.static \
      -X ${mirror}/${VERSION}/main \
      -U \
      --allow-untrusted \
      --root ././${CHROOT} \
      --initdb add alpine-base 
  
  if [ "${PACKAGES}" ]; then
      set_resolv     
      chroot ${CHROOT} /sbin/apk --no-cache update
      chroot ${CHROOT} /sbin/apk --no-cache add ${PACKAGES}
  fi
fi
  
# Cleaning up
rm -f ${CHROOT}/sbin/apk.static ${CHROOT}/var/cache/apk/*

if [ ${DOCKER} ]; then
    BASE="`basename ${CHROOT}`"
    tar --numeric-owner -c -C ${CHROOT} . | docker import  -c "CMD /bin/sh" - ${BASE}
fi

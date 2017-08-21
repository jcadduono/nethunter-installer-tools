## Nethunter Installer Tools

This was created by @jcadduono to help build Android binaries for use in Nethunter.  I have added a few more binaries (such as nmap/socat/dropbear).  These can all be run on your android device with some planning

## Instructions

Docker is the easiest way to build android binaries for all your devices.

Before running, modify the env.list file to point to where your Android ARM device should look for the file folders.  This is probably going to be in /data/local but if you plan to run this manually.  Otherwise, if you plan to include folder in an app you would want to point to your app folder.

## Docker Run

To easily build, run the following commands with docker installed:

```
mkdir -p out
docker build . -t nh-tools
docker run --env-file ./env.list -v "`pwd`/out:/root/nethunter-installer-tools/out/" -t nh-tools
```

Output binaries will be located in the "out" folder that is created.

If you would rather run it from a command line for testing:
```
docker run -i -t --entrypoint /bin/bash -t nh-tools
```

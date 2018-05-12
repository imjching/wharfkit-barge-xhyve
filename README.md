# BargeOS running on xhyve hypervisor

> Build specifically for **wharfkit**, a tool just like `docker-machine`, but with faster boot time and uses less space and memory.

This is a toolbox to run [Barge OS](https://github.com/bargees/barge-os) on xhyve hypervisor easily.

## Features

- [Barge OS](https://github.com/bargees/barge-os)
- Disable TLS
- Expose the official IANA registered Docker port 2375

## How does this compare to barge-xhyve?

- Updated Docker to the latest version: 18.03.1-ce.
- Set default disk space to 2GB instead of 4GB.
- No Linux swap space.
- Removed password for user `bargee`.
- Allow empty passwords during SSH.
- Hostname can now be passed into the VM through `/proc/cmdline` during boot and it will be configured accordingly. (See `barge.hostname`).
- Removed NFS synced folder for now. It might be re-added at a later time.

## Requirements

- [xhyve](https://github.com/mist64/xhyve)
  - Mac OS X Yosemite 10.10.3 or later
  - A 2010 or later Mac (i.e. a CPU that supports EPT)

## Caution

- **Kernel Panic** will occur on booting, if VirtualBox (< v5.0) has run before.
- Pay attention to **exposing the port 2375 without TLS**, as you see the features.

## Installing xhyve

```
$ git clone https://github.com/mist64/xhyve
$ cd xhyve
$ make
$ cp build/xhyve /usr/local/bin/    # You may require sudo
```

or

```
$ brew install xhyve
```

## Setting up Barge images and tools

```
$ git clone https://github.com/imjching/wharfkit-barge-xhyve
$ cd wharfkit-barge-xhyve
$ make init
```

## Booting Up

```
$ sudo ./xhyverun.sh [<dir>]

Welcome to Barge barge /dev/ttyS0
barge login:
```

or

```
$ make up    # You may be asked for your sudo password
Booting up...
```

- On Terminal.app: This will open a new window, then you will see in the window as below.
- On iTerm 2.app: This will split the current window, then you will see in the bottom pane as below.

```
Welcome to Barge barge /dev/ttyS0
barge login:
```

## Logging In

- ID: bargee

```
$ make ssh
barge-xhyve: running on 192.168.65.6
Welcome to Barge 2.8.2, Docker version 18.03.1-ce, build 9ee9f40
[bargee@barge ~]$
```

## Shutting Down

Use `halt` command to shut down in the VM:

```
[bargee@barge ~]$ sudo halt
halt[324]: Executing shutdown scripts in /etc/init.d
Stopping crond... OK
docker[332]: Loading /etc/default/docker
docker[332]: Stopping Docker daemon
Stopping sshd... OK
Saving random seed... done.
halt[324]: halt
[bargee@barge ~]$ reboot: System halted
$
```

or, use `make halt` on the host:

```
$ make halt
barge-xhyve: running on 192.168.65.6
halt[326]: Executing shutdown scripts in /etc/init.d
Stopping crond... OK
docker[334]: Loading /etc/default/docker
docker[334]: Stopping Docker daemon
Stopping sshd... OK
Saving random seed... done.
halt[326]: halt
Connection to 192.168.65.6 closed by remote host.
Shutting down...
```

## Using Docker

You can simply run Docker within the VM. However, if you install the Docker client on the host, you can use Docker commands natively on the host Mac. Install the Docker client as follows:

```
$ curl -L https://get.docker.com/builds/Darwin/x86_64/docker-latest -o docker
$ chmod +x docker
$ mv docker /usr/local/bin/    # You may require sudo
```

Alternatively install with Homebrew:

```
$ brew install docker
```

Then, in the VM, or on the host if you have installed the Docker client:

```
$ make env
barge-xhyve: running on 192.168.65.6
export DOCKER_HOST=tcp://192.168.65.6:2375;
unset DOCKER_CERT_PATH;
unset DOCKER_TLS_VERIFY;
$ eval $(make env)
barge-xhyve: running on 192.168.65.6

$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 18.03.1-ce
Storage Driver: overlay
 Backing Filesystem: extfs
 Supports d_type: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 773c489c9c1b21a6d78b5c538cd395416ec50f88
runc version: 4fc53a81fb7c994640722ac585fa9ca548971871
init version: 949e6fa
Security Options:
 seccomp
  Profile: default
Kernel Version: 4.14.39-barge
Operating System: Barge 2.8.2
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 995.7MiB
Name: barge
ID: QPFB:23X7:VNQH:UWGM:JYYR:FGMJ:VHLF:4JRD:TJLC:YNLD:5QFX:V77O
Docker Root Dir: /mnt/data/var/lib/docker
Debug Mode (client): false
Debug Mode (server): true
 File Descriptors: 19
 Goroutines: 33
 System Time: 2018-05-11T23:38:12.534244947Z
 EventsListeners: 0
Registry: https://index.docker.io/v1/
Labels:
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
```

## Upgrading Barge

When Barge is upgraded and barge-xhyve is updated,

```
$ git pull origin master
$ make upgrade
$ make up
$ make ssh
[bargee@barge ~]$ sudo cp /etc/init.d/start.sh /etc/init.d/start.old
[bargee@barge ~]$ sudo wget -qO /etc/init.d/start.sh https://raw.githubusercontent.com/imjching/wharfkit-barge-xhyve/master/contrib/configs/start.sh
[bargee@barge ~]$ sudo chmod +x /etc/init.d/start.sh
[bargee@barge ~]$ sudo reboot
```

## Resources

- /var/db/dhcpd_leases (default with xhyve)

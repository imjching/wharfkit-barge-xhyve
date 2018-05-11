# Making a fresh persistent disk

## Make a blank disk image on Max OS X

2GB (recommended) for example

```
$ dd if=/dev/zero of=vm/barge-data.img bs=1g count=2
4+0 records in
4+0 records out
2147483648 bytes transferred in 7.409610 secs (289824112 bytes/sec)
```

## Set up a persistent disk

- Boot it on xhyve
- Download and execute [makehdd.sh](https://github.com/imjching/wharfkit-barge-xhyve/blob/master/contrib/makehdd/makehdd.sh)

```
$ sudo ./xhyverun.sh

Welcome to Barge barge /dev/ttyS0
barge login: bargee
Password:
Welcome to Barge 2.8.2, Docker version 18.03.1-ce, build 9ee9f40
[bargee@barge ~]$ wget https://raw.githubusercontent.com/imjching/wharfkit-barge-xhyve/master/contrib/makehdd/makehdd.sh
[bargee@barge ~]$ chmod +x makehdd.sh
[bargee@barge ~]$ sudo ./makehdd.sh
[bargee@barge ~]$ sudo fdisk -l
Disk /dev/vda: 2048 MB, 2147483648 bytes, 4194304 sectors
2048 cylinders, 64 heads, 32 sectors/track
Units: cylinders of 2048 * 512 = 1048576 bytes

Device  Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
/dev/vda1    0,1,1       1023,63,32          32    4194303    4194272 2047M 83 Linux
[bargee@barge ~]$ df
Filesystem           1K-blocks      Used Available Use% Mounted on
tmpfs                   917648    150656    766992  16% /
devtmpfs                495508         0    495508   0% /dev
tmpfs                   509804         0    509804   0% /run
cgroup                  509804         0    509804   0% /sys/fs/cgroup
tmpfs                   917648    150656    766992  16% /var/lib/docker
/dev/vda1              1933120      6192   1805688   0% /mnt/vda1
overlay                1933120      6192   1805688   0% /etc
[bargee@barge ~]$ ls -l /etc/default/docker
-rw-r--r--    1 root     root             0 May 11 04:59 /etc/default/docker
[bargee@barge ~]$ ls -l /etc/init.d/start.sh
-rwxr-xr-x    1 root     root             0 May 11 04:59 /etc/init.d/start.sh*
[bargee@barge ~]$ ls -l /etc/init.d/init.sh
-rwxr-xr-x    1 root     root             0 May 11 04:59 /etc/init.d/init.sh*
[bargee@barge ~]$ sudo halt
halt[422]: Executing shutdown scripts in /etc/init.d
Stopping crond... OK
docker[430]: Loading /etc/default/docker
docker[430]: Stopping Docker daemon
Stopping sshd... OK
Stopping haveged: stopped /usr/sbin/haveged (pid 87)
OK
Saving random seed... done.
halt[422]: halt
[bargee@barge ~]$ logout
```

Done.

class { 'tungsten': installSSHKeys => true, installMysql=> false,
    disableFirewall=> false, skipHostConfig=> true,docker => true   ,  xtraBackupPackage=>'/mnt/xtrabackup/percona-xtrabackup-2.2.12-1.el6.x86_64.rpm'    }

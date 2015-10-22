if ($operatingsystem =~ /(?i:debian|ubuntu)/) {
  case $::lsbdistcodename {
    'squeeze':   { $download = "percona-xtrabackup_2.2.8-5059-1.squeeze_amd64.deb" }
    "wheezy":    { $download = "percona-xtrabackup_2.2.8-5059-1.wheezy_amd64.deb" }
    'lucid':     { $download = "percona-xtrabackup_2.2.8-5059-1.lucid_amd64.deb"}
    'precise':   { $download = "percona-xtrabackup_2.2.8-5059-1.precise_amd64.deb"}
    'trusty':    { $download = "percona-xtrabackup_2.2.8-5059-1.trusty_amd64.deb" }
  }
} else {
 case $::operatingsystemmajrelease {
   6:          { $download = "percona-xtrabackup-2.2.12-1.el6.x86_64.rpm" }
   7:          { $download = "percona-xtrabackup-2.2.12-1.el7.x86_64.rpm"  }
   }
}
class { 'tungsten': installSSHKeys => true, installMysql=> true,
      disableFirewall=> false, skipHostConfig=> true,docker => true  }

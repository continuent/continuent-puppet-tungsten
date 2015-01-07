class { 'tungsten': installSSHKeys => true, installMysql=> true, disableSELinux=>false,overrideOptionsMysqld=>{'port'=>'3306'}, disableFirewall=> false, skipHostConfig=> true }

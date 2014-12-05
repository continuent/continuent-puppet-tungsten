class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat'{
    class { 'selinux':
      mode => 'permissive'
     }
    }
  }

}
class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat' and  $operatingsystemmajrelease > 5 {

            class { 'selinux':
              mode => 'permissive'
            }

    }
  }

}
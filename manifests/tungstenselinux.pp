class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat' and  $operatingsystemmajrelease > 5 {
        if $::operatingsystem != 'Amazon' {
          class { 'selinux':
          mode => 'permissive'
          }
        }

    }
  }

}
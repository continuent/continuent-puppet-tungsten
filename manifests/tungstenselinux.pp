class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat'{
        if $operatingsystemmajrelease == 5 {
            class { 'selinux':
              mode => 'disabled'
            }
          } else {
            class { 'selinux':
              mode => 'permissive'
            }
          }
    }
  }

}
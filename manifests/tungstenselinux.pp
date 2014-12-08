class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat'{
        if $operatingsystemmajrelease == 5 {
          file { '/etc/selinux/config':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0744',
            content => "#Dummy file"
          }->
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
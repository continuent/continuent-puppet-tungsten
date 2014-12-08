class tungsten::tungstenselinux(
  $disableSELinux							= true,
) {

  if $disableSELinux == true {
    if $::osfamily == 'RedHat'{
        if $operatingsystemmajrelease == 5 {
          file { 'tmp-selinux-config':
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0744',
            path    => '/etc/selinux/config',
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
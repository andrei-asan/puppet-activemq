class activemq::config(
  $version = undef,
  $persistence_db_driver_version = '6'
){

  $major_version_withoutrelease = regsubst($version, '^(\d+\.\d+)\.\d+-.*$','\1')
  notice("major_version_withoutrelease=${major_version_withoutrelease}")

  file { '/data/activemq':
    ensure => directory,
    owner  => 'activemq',
    group  => 'activemq'
  }

  file { '/data/activemq/heapdumps':
    ensure  => directory,
    owner   => 'activemq',
    group   => 'activemq',
    require => File['/data/activemq']
  }

  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease < 7 {
        file { '/etc/init.d/activemq':
          ensure  => file,
          mode    => '0755',
          content => template("${module_name}/init/activemq"),
        }
      }
    }
  }

  file { '/etc/activemq':
    ensure => directory
  }

  file { '/etc/activemq/activemq.xml':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/${version_real}/activemq.xml.erb"),
    replace => false,
    notify  => Class['activemq::service'],
    require => File['/etc/activemq']
  }

  file { '/etc/activemq/activemq-wrapper.conf':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/v${major_version_withoutrelease}/activemq-wrapper.conf.erb"),
    notify  => Class['activemq::service']
  }

  file { '/etc/activemq/jetty-realm.properties':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/jetty-realm.properties.erb"),
    notify  => Class['activemq::service']
  }

  file { "/usr/share/activemq/lib/ojdbc${persistence_db_driver_version}.jar":
    ensure => file,
    source => "puppet:///modules/${module_name}/drivers/oracle/ojdbc${persistence_db_driver_version}.jar"
  }

  file { '/usr/share/activemq/lib/mysql-connector-java.jar':
    ensure => file,
    source => "puppet:///modules/${module_name}/drivers/mysql/mysql-connector-java-5.1.33.jar"
  }

}

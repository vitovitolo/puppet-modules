class dns 
(
	$forwarders = [],
	$secret = "",
	$listen_on = "any",
)
{
	package {"bind9":
		ensure  => "installed",
		require => Exec["apt-get-update"],
	}
	service {"bind9":
		ensure     => "running",
		hasstatus  => true,
		hasrestart => true,
		enable     => true,
		require    => Package["bind9"],
		restart    => "/usr/sbin/named-checkconf && /etc/init.d/bind9 reload"
	}
	file {"/etc/bind/zones.conf":
		ensure  => directory,
		owner   => "root",
		group   => "bind",
		mode    => 0775,
		require => Package["bind9"],
	}
	file {"/etc/bind/zones.db":
		ensure  => directory,
		owner   => "root",
		group   => "bind",
		mode    => 0775,
		require => Package["bind9"],
	}

	$dns_forwarders = $forwarders
	file {"/etc/bind/named.conf.options":
		ensure => "file",
		require => Package["bind9"],
		notify  => Service["bind9"],
		content => template("dns/named.conf.options.erb"),
	}

	concat {"/etc/bind/named.conf.local":
		ensure  => "present",
		require => Package["bind9"],
		owner   => "root",
		group   => "root",
		mode    => 0644,
		notify  => Service["bind9"],
	}
	if $secret != "" {
		file {"/etc/bind/rndc.key":
			ensure  => file,
			require => Package["bind9"],
			owner   => "bind",
			group   => "bind",
			mode    => 0640,
			notify  => Service["bind9"],
			content => template("dns/named.conf.local.rndc-key.erb"),
		}
		concat::fragment {"named.conf.local-rndc-key":
			target  => "/etc/bind/named.conf.local",
			content => template("dns/named.conf.local.rndc-key.erb"),
			order   => 10,
		}
	}
	file {"/etc/default/bind9":
		ensure  => "file",
		require => Package["bind9"],
		owner   => "root",
		group   => "root",
		mode    => 0644,
		content => template("dns/default.erb"),
	}
	file {"/etc/bind/.set_db_serial.sh":
		ensure  => "file",
		require => Package["bind9"],
		owner   => "root",
		group   => "root",
		mode    => 0700,
		source  => "puppet:///modules/dns/set_db_serial.sh",
	}
}

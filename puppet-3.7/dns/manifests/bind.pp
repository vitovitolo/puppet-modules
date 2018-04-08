class dns::bind
(
	$forwarders = [],
	$ip = "0.0.0.0",

	$check_condition = "true",
	$check_hostname = "",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",
)
{
	package {"bind9":
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
	service {"bind9":
		ensure  => running,
		require => Package["bind9"],
		restart => "/usr/sbin/named-checkconf && /usr/sbin/service bind9 reload",
	}
	file {["/etc/bind/zones.conf", "/etc/bind/zones.db"]:
		ensure  => directory,
		owner   => "root",
		group   => "bind",
		mode    => 0755,
		require => Package["bind9"],
	}
	file {"/etc/bind/named.conf.options":
		ensure  => file,
		content => template("dns/named.conf.options.erb"),
		require => Package["bind9"],
		notify  => Service["bind9"],
	}
	file {"/etc/default/bind9":
		ensure  => file,
		require => Package["bind9"],
		notify  => Service["bind9"],
		content => template("dns/default.erb"),
	}
	concat {"/etc/bind/named.conf.local":
		ensure  => "present",
		require => Package["bind9"],
		owner   => "root",
		group   => "root",
		mode    => 0644,
		notify  => Service["bind9"],
	}
	concat::fragment {"00_named.conf.local_header":
		target  => "/etc/bind/named.conf.local",
		content => template("concat/fileheader.erb"),
		order   => 00,
	}
}

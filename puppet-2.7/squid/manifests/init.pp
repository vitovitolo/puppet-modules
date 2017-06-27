class squid
(
	$listen_port = "3128",
)
{
	package{"squid":
		ensure  => "installed",
	}
	service {"squid":
		ensure     => "running",
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		require    => Package["squid"],
	}
	file {"/etc/squid/acl.d":
		ensure  => directory,
		require => Package["squid"],
	}
	file {"/etc/squid/acl.d/00_acl_header.conf":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0600,
		content => template("squid/acl_header.conf.erb"),
		require => [Package["squid"],File["/etc/squid/acl.d"]],
		notify  => Service["squid"],
	}
	file {"/etc/squid/acl.d/99_acl_footer.conf":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0600,
		content => template("squid/acl_footer.conf.erb"),
		require => [Package["squid"],File["/etc/squid/acl.d"]],
		notify  => Service["squid"],
	}
	$squid_listen_port = $listen_port
	file {"/etc/squid/squid.conf":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0600,
		content => template("squid/squid.conf.erb"),
		require => Package["squid"],
		notify  => Service["squid"],
	}
	file {"/etc/squid/regex.d":
		ensure  => directory,
		owner   => "root",
		group   => "root",
		mode    => 0755,
		require => Package["squid"],
	}
}

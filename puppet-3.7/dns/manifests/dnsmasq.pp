class dns::dnsmasq
(
	$ip = "0.0.0.0",
	$local_domain = "",

)
{
	package {"dnsmasq":
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
	service {"dnsmasq":
		ensure    => running,
		require   => Package["dnsmasq"],
		restart   => "/usr/sbin/service dnsmasq reload",
		subscribe => File["/etc/hosts"],
	}
	file {"/etc/dnsmasq.conf":
		ensure  => file,
		content => template("dns/dnsmasq.conf.erb"),
		require => Package["dnsmasq"],
		notify  => Service["dnsmasq"],
	}
}

define dns::dynamic_key
(
	$key_name="${name}",
	$secret=hiera("dns::dynamic_key::${name}::secret", ""),
)
{
	include dns::bind
	file {"/etc/bind/$name.key":
		ensure  => file,
		require => Package["bind9"],
		owner   => "bind",
		group   => "bind",
		mode    => 0640,
		content => template("dns/named.conf.local.key.erb"),
	}
	concat::fragment {"10_named.conf.local_key_${name}":
		target  => "/etc/bind/named.conf.local",
		content => template("dns/named.conf.local.key.erb"),
		order   => 10,
	}
}

define dns::zone
(
	$type,
	$forwarders = [],
	$masters = [],
	$slaves = [],
	$allow_transfer_from = [],
	$dynamic_key = "",
)
{
	include dns::bind
	$config_file = "/etc/bind/zones.conf/named.conf.${name}"
	$db_file = "/etc/bind/zones.db/db.${name}"
	$allow_transfer = flatten([$slaves, $allow_transfer_from])
	concat::fragment {"named.conf.local-zone-$name":
		target  => "/etc/bind/named.conf.local",
		content => template("dns/named.conf.local.zone.erb"),
		order   => 50,
	}
	file {"$config_file":
		ensure  => "file",
		require => File["/etc/bind/zones.conf"],
		notify  => Service["bind9"],
		owner   => "root",
		group   => "bind",
		mode    => 0644,
		content => template("dns/zone.conf.erb"),
	}
}

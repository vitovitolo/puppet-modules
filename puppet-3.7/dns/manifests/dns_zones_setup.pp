class dns::dns_zones_setup
{
	$dnszonesdir="/var/lib/puppet/dns_zones_tmp"
	file {"$dnszonesdir":
		ensure => directory,
		mode   => 0750,
	}
	file {"$dnszonesdir/bin":
		ensure => directory,
		mode   => 0750,
	}
	file {"$dnszonesdir/bin/set_db_serial.sh":
		ensure  => file,
		require => Package["bind9"],
		owner   => "root",
		group   => "root",
		mode    => 0750,
		content => template("dns/set_db_serial.sh.erb"),
	}
}

define dns::zone
(
	$dynamic = false,
	$reverse = false,
	$reverse_range = "10",
	$reverse_dns = "example.com.",
	$ns = "ns",
	$environment = "",
	$entries = "",
	$type = "master",
	$master = "",
	$forwarders = [],
	$slaves = [],
	$allowtransfer = ["none"],
	$refresh = "120",
	$retry = "60",
	$expire = "1209600",
	$neg_cache = "600",
	$ttl = "3600"
)
{
	include dns
	$zone_dynamic = $dynamic
	$zone_reverse = $reverse
	$zone_reverse_range = $reverse_range
	$zone_reverse_dns = $reverse_dns
	$zone_db_file = "/etc/bind/zones.db/db.${name}"
	$zone_db_tmp_file = "/etc/bind/zones.db/.db.${name}"
	$zone_config_file = "/etc/bind/zones.conf/named.conf.${name}"
	$zone_name = $name
	$zone_environment = $environment
	$zone_type = $type
	$zone_master = $master
	$zone_forwarders = $forwarders
	$zone_slaves = $slaves
	$zone_allowtransfer = $allowtransfer
	$zone_ttl = $ttl
	$zone_ns = $ns
	$zone_entries = $entries
	$zone_refresh = $refresh
	$zone_retry = $retry
	$zone_expire = $expire
	$zone_neg_cache = $neg_cache

	file {"$zone_config_file":
		ensure  => "file",
		require => [Package["bind9"],File["/etc/bind/zones.conf"]],
		notify  => Service["bind9"],
		owner   => "root",
		group   => "bind",
		mode    => 0644,
		content => template("dns/zone.conf.erb"),
	}
	if $type == "master" {
		concat {"$zone_db_tmp_file":
			ensure  => "present",
			require => [Package["bind9"],File["/etc/bind/zones.db"]],
			notify  => Service["bind9"],
			owner   => "root",
			group   => "bind",
			mode    => 0644,
		}
		concat::fragment {"zone_db_header_${name}":
			target  => "$zone_db_tmp_file",
			content => template("dns/db.zone.header.erb"),
			order   => 01,
		}
		if $reverse {
			if $dynamic {
				$zonetemplate="db.zone.dynamic-reverse.erb"
			} else {
				$zonetemplate="db.zone.reverse.erb"
			}
		} else {
			if $dynamic {
				$zonetemplate="db.zone.dynamic.erb"
			} else {
				$zonetemplate="db.zone.machines.erb"
			}
		}
		concat::fragment {"zone_db_machines_${name}":
			target  => "$zone_db_tmp_file",
			content => template("dns/$zonetemplate"),
			order   => 99,
		}
		$set_db_serial = "/etc/bind/.set_db_serial.sh"
		$set_db_serial_cmd = "$set_db_serial $zone_db_tmp_file $zone_db_file"
		exec {"$set_db_serial_cmd":
			path    => [ "/bin", "/usr/bin" ],
			require => [ File["$set_db_serial"], File["$zone_db_tmp_file"] ],
			unless  => "$set_db_serial_cmd -t",
			notify  => Service["bind9"],
		}
	}
	concat::fragment {"include-zone-$name":
		target  => "/etc/bind/named.conf.local",
		content => template("dns/named.conf.local.zone.erb"),
		order   => 50,
	}
}

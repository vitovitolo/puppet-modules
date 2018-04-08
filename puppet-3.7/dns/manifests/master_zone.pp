define dns::master_zone
(
	$forwarders = hiera("dns::zone::${name}::forwarders", hiera("dns::zone::forwarders", [])),
	$masters = hiera("dns::zone::${name}::masters", hiera("dns::zone::masters", [])),
	$slaves = hiera("dns::zone::${name}::slaves", hiera("dns::zone::slaves", [])),
	$allow_transfer_from = hiera("dns::zone::${name}::allow_transfer_from", hiera("dns::zone::allow_transfer_from", [])),
	$dynamic_key = hiera("dns::zone::${name}::dynamic_key", hiera("dns::zone::dynamic_key", "")),
	$content = hiera("dns::zone::${name}::content", ""),
	$ns = hiera("dns::zone::${name}::ns", hiera("dns::zone::ns", "dns")),
	$ttl = hiera("dns::zone::${name}::ttl", hiera("dns::zone::ttl", "3600")),
	$refresh = hiera("dns::zone::${name}::refresh", hiera("dns::zone::refresh", "120")),
	$retry = hiera("dns::zone::${name}::retry", hiera("dns::zone::retry", "60")),
	$expire = hiera("dns::zone::${name}::expire", hiera("dns::zone::expire", "1209600")),
	$neg_cache = hiera("dns::zone::${name}::neg_cache", hiera("dns::zone::neg_cache", "600")),
	$entries = hiera_hash("dns::zone::${name}::entries", undef),
)
{
	include dns::dns_zones_setup
	dns::zone {"${name}":
		type                => "master",
		forwarders          => $forwarders,
		masters             => $masters,
		slaves              => $slaves,
		allow_transfer_from => $allow_transfer_from,
		dynamic_key         => $dynamic_key,
	}
	$db_file = "/etc/bind/zones.db/db.${name}"
	$tmpzonesdir = $dns::dns_zones_setup::dnszonesdir
	$db_tmp_file = "$tmpzonesdir/db.${name}"
	concat {"$db_tmp_file":
		ensure  => "present",
		require => File["$tmpzonesdir"],
		notify  => Service["bind9"],
		owner   => "root",
		group   => "bind",
		mode    => 0644,
	}
	$set_db_serial = "$tmpzonesdir/bin/set_db_serial.sh"
	$set_db_serial_cmd = "$set_db_serial $db_tmp_file $db_file"
	exec {"$set_db_serial_cmd":
		path    => [ "/bin", "/usr/bin" ],
		require => [ File["$set_db_serial"], File["$db_tmp_file"], Package["bind9"] ],
		unless  => "$set_db_serial_cmd -t",
		notify  => Service["bind9"],
	}
	concat::fragment {"zone_db_${name}_00_header":
		target  => "$db_tmp_file",
		content => template("dns/db.zone.header.erb"),
		order   => "000",
	}
	if $content != "" {
		dns::master_zone_data{"zone_${name}_basic_data":
			zone    => "$name",
			content => $content,
			order   => "100",
		}
	}
	if $entries {
		$entry_defaults = {
			zone  => "$name",
			order => "100",
		}
		create_resources(dns::master_zone_data, $entries, $entry_defaults)
	}
}

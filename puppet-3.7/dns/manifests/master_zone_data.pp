define dns::master_zone_data
(
	$zone,
	$content = "",
	$order = "555",
)
{
	include dns::dns_zones_setup
	$tmpzonesdir = $dns::dns_zones_setup::dnszonesdir
	$db_tmp_file = "$tmpzonesdir/db.${zone}"
	$entries = flatten([$content])
	concat::fragment {"zone_db_${zone}_data_${name}":
		target  => $db_tmp_file,
		content => template("dns/db.zone.entries.erb"),
		order   => $order,
	}
}

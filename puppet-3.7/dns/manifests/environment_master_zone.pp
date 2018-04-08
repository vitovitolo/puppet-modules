define dns::environment_master_zone
(
	$forwarders = hiera("dns::zone::${name}::forwarders", hiera("dns::zone::forwarders", [])),
	$masters = hiera("dns::zone::${name}::masters", hiera("dns::zone::masters", [])),
	$slaves = hiera("dns::zone::${name}::slaves", hiera("dns::zone::slaves", [])),
	$allow_transfer_from = hiera("dns::zone::${name}::allow_transfer_from", hiera("dns::zone::allow_transfer_from", [])),
	$dynamic_key = hiera("dns::zone::${name}::dynamic_key", hiera("dns::zone::dynamic_key", "")),
	$content = hiera("dns::zone::${name}::content", ""),
	$ns = hiera("dns::zone::${name}::ns", hiera("dns::zone::ns", "dns")),
	$environment = hiera("dns::zone::${name}::environment", "$name"),
	$ttl = hiera("dns::zone::${name}::ttl", hiera("dns::zone::ttl", "3600")),
	$refresh = hiera("dns::zone::${name}::refresh", hiera("dns::zone::refresh", "120")),
	$retry = hiera("dns::zone::${name}::retry", hiera("dns::zone::retry", "60")),
	$expire = hiera("dns::zone::${name}::expire", hiera("dns::zone::expire", "1209600")),
	$neg_cache = hiera("dns::zone::${name}::neg_cache", hiera("dns::zone::neg_cache", "600")),
)
{
	dns::master_zone{"$name":
		forwarders          => $forwarders,
		masters             => $masters,
		slaves              => $slaves,
		allow_transfer_from => $allow_transfer_from,
		dynamic_key         => $dynamic_key,
		content             => $content,
		ns                  => $ns,
		ttl                 => $ttl,
		refresh             => $refresh,
		retry               => $retry,
		expire              => $expire,
		neg_cache           => $neg_cache,
	}
	dns::master_zone_data{"zone_${name}_environment_data":
		zone    => "$name",
		content => template("ds/db.zone.environment.erb"),
		order   => "200",
	}
}

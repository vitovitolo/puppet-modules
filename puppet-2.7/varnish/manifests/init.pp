class varnish (
	$bind_address="0.0.0.0",
	$bind_port="6081",
	$bind_management_address="127.0.0.1",
	$bind_management_port="6082",
	$management_secret="s3cr3t",
	$storage_backend_options=["malloc,256m"],
	$backend_address="127.0.0.1",
	$backend_port="8080",
	$ulimit_openfiles="131072",
	$ulimit_lockedmem="82000",
	$cache_ttl="120",
	$no_cache_404 = true,
)
{
	$varnish_bind_address            = $bind_address
	$varnish_bind_port               = $bind_port
	$varnish_bind_management_address = $bind_management_address
	$varnish_bind_management_port    = $bind_management_port
	$varnish_management_secret       = $management_secret
	$varnish_storage_backend_options = $storage_backend_options
	$varnish_backend_address         = $backend_address
	$varnish_backend_port            = $backend_port
	$varnish_ulimit_openfiles        = $ulimit_openfiles
	$varnish_ulimit_lockedmem        = $ulimit_lockedmem
	$varnish_cache_ttl               = $cache_ttl
	$varnish_monitoring              = $monitoring

	aptclient::extrarepo {"varnish-cache":
		gpg     => template("aptclient/varnish-cache.gpg.erb"),
		sources => template("aptclient/varnish-cache.list.erb"),
	}
	package{"varnish":
		require => Exec["apt-get-update"]
	}
	file {
		"/etc/default/varnish":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => 644,
			content => template("varnish/varnish_init_default.erb"),
			require => Package ["varnish"],
			notify  => Service["varnish"];

		"/etc/varnish/secret":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => 600,
			content => template("varnish/varnish_mgm_secret.erb"),
			require => Package ["varnish"],
			notify  => Service["varnish"];

		"/etc/varnish/default.vcl":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => 644,
			content => template("varnish/varnish_cfg_default.erb"),
			require => Package ["varnish"],
			notify  => Service["varnish"];
	}
	service { "varnish":
		ensure     => "running",
		enable     => true,
		hasrestart => true,
		hasstatus  => true,
		restart    => "service varnish reload",
		require    => Package["varnish"],
	}
}


define rsyncd::module
(
	$path = "/tmp",
	$max_connections = "1",
	$timeout = "60",
	$uid = "",
	$gid = "",
	$read_only = false,
	$write_only = true,
	$list = true,
	$munge_symlinks = "false",
	$in_chmod = "",
	$prexfer_exec = "",
	$postxfer_exec = "",
	$secrets = undef,
)
{
	include rsyncd
	concat::fragment {"ensure_rsync_directories_$name":
		target  => "/usr/local/sbin/ensure_rsync_directories",
		order   => "555",
		content => template("rsyncd/rsyncd.ensure_path.erb"),
	}
	concat::fragment {"rsyncd.conf-500-$name":
		target  => "/etc/rsyncd.conf",
		order   => "500",
		content => template("rsyncd/rsyncd.module.conf.erb"),
	}
	concat {"/etc/rsyncd.secrets.${name}":
		ensure => present,
		owner  => "root",
		group  => "root",
		mode   => 0600,
	}
	concat::fragment{"rsyncd.secrets.$name.000-header":
		target  => "/etc/rsyncd.secrets.${name}",
		content => template("concat/fileheader.erb"),
		order   => "000",
	}
	if $secrets {
		$secret_defaults = {
			module => $name,
		}
		create_resources(rsyncd::secret, $secrets, $secret_defaults)
	}
}

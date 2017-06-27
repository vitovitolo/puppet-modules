define smtp::hash_file
(
	$fpath = "$name",
	$content = "",
)
{
	concat {"$fpath":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => "0644",
		require => Package["postfix"],
		notify  => Exec["update-$name"],
	}
	concat::fragment{"000-$fpath":
		target  => "$fpath",
		content => "#file managed by puppet
",
		order   => "000",
	}
	exec {"update-$name":
		path    => ["/sbin","/bin","/usr/sbin","/usr/bin"],
		command => "/usr/sbin/postmap '$fpath'",
		creates => "$fpath.db",
		notify  => Service["postfix"],
	}
}

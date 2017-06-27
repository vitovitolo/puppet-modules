define smtp::hash_file
(
	$fpath = "$name",
	$update_cmd = "postmap",
)
{
	concat {"$fpath":
		ensure  => present,
		owner   => "root",
		group   => "postfix",
		mode    => "0640",
		require => Package["postfix"],
		notify  => Exec["update-$name"],
	}
	concat::fragment{"000-$fpath":
		target  => "$fpath",
		content => template("concat/fileheader.erb"),
		order   => "000",
	}
	exec {"update-$name":
		path    => ["/sbin","/bin","/usr/sbin","/usr/bin"],
		command => "/usr/sbin/$update_cmd '$fpath'",
		creates => "$fpath.db",
		notify  => Service["postfix"],
	}
	file {"$fpath.db":
		require => Exec["update-$name"],
		owner   => "root",
		group   => "postfix",
		mode    => "0640",
	}
}

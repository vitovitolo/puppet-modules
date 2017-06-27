class rsyncd::setup
(
	$port = "873",
	$chroot = "yes",
)
{

	concat {"/etc/rsyncd.conf":
		ensure => present,
		owner  => "root",
		group  => "root",
		mode   => 0644,
		require => Package["rsync"],
		notify  => Service["rsync"],
	}
	concat::fragment {"rsyncd.header.conf":
		target  => "/etc/rsyncd.conf",
		content => template("rsyncd/rsyncd.header.conf.erb"),
		order   => "000",
	}

	service{"rsync":
		ensure     =>"running",
		hasstatus  =>true,
		hasrestart =>true,
		enable     =>true,
		require    => Package["rsync"],
	}
	file {"/etc/default/rsync":
		ensure  => "present",
		owner   => "root",
		group   => "root",
		content => template("rsyncd/rsyncd.default.erb"),
		require => Package["rsync"],
	}

}

class ipvs
(
)
{
	include router

	package {"ipvsadm":
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
	file {"/etc/ipvsadm.rules":
		ensure  => absent,
		owner   => "root",
		group   => "root",
		mode    => 0644,
	}
}

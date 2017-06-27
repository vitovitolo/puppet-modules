class rsyncd
(
)
{
	package {"rsync":
		ensure  =>"latest",
		require => Exec["apt-get-update"],
	}
}

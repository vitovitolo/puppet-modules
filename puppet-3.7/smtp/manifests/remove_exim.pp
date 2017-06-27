class smtp::remove_exim
(
)
{
	package {["exim4","exim4-base","exim4-config"]:
		ensure  => purged,
		require => Exec["apt-get-update"],
	}
}

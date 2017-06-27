class bonding {
	package {"ifenslave-2.6": 
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
}

class sonar (
	$version = "4.3.2",

	$check_condition = "true",
	$check_hostname = "",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",
)
{
	include java

	package {"apt-transport-https":
		ensure  => "installed",
	}
	package {"sonar":
		ensure  => "${version}",
		require => [Exec["apt-get-update"],File["/etc/apt/sources.list.d/sonar.list"],Package["apt-transport-https"]],
	}
	file {"/etc/apt/sources.list.d/sonar.list":
		ensure  => file,
		content => template("sonar/sonar.list.erb"),
		notify  => Exec["apt-get-update"],
	}
	service {"sonar":
		enable      => true,
		ensure      => running,
		require    => Package["sonar"]
	}
}

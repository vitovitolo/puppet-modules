class statsd(
	$config_dir = "/etc/statsd",
	$log_dir = "/var/log/statsd",
	$listen_port = "8125",
	$graphite_host = "localhost",
	$graphite_port = "2003",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",

) {

	include apt::wartortle

	package {"statsd":
			ensure         => installed,
	        	require        => Exec["apt-get-update"],
	}
	service {"statsd":
		ensure => running,
	}
	file {
		"${log_dir}":
			ensure  => directory,
			require => Package["statsd"];

		#configuration file
		"${config_dir}/localConfig.js":
			ensure  => file,
			content => template("statsd/localConfig.js.erb"),
			require => Package["statsd"],
			notify => Service["statsd"];

	}
}

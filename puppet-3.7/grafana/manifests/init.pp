class grafana
(
	$config_dir = "/etc/grafana",
	$data_dir = "/var/lib/grafana",
	$log_dir = "/var/log/grafana",
	$http_addr = "0.0.0.0",
	$http_port = "3000",

	$check_condition = "true",
	$check_hostname = "",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",

) {

	include apt::wartortle
	include apache

	$domain = get_env_dnsdomain("$environment")

	apache::site {"grafana":
		enabled  => true,
		ip       => "0.0.0.0",
		port     => 80,
		template => "grafana/apache_site_grafana.erb",
	}
	exec {"/usr/sbin/a2enmod proxy":
		unless => "/usr/sbin/a2query -m proxy",
		require => Package["apache2"],
	}
	exec {"/usr/sbin/a2enmod proxy_http":
		unless => "/usr/sbin/a2query -m proxy_http",
		require => Package["apache2"],
	}

	package {"grafana":
			ensure         => installed,
	        	require        => Exec["apt-get-update"],
	}
	service {"grafana-server":
		ensure => running,
		require => Package["grafana"],
	}
	file {"/etc/default/grafana-server":
			ensure  => file,
			owner   => "grafana",
			group   => "grafana",
			content => template("grafana/default_grafana-server.erb"),
			require => Package["grafana"],
			notify => Service["grafana-server"];
		"${log_dir}":
			ensure  => directory,
			owner   => "grafana",
			group   => "grafana",
			require => Package["grafana"];

		#Graphite-web configuration
		"${config_dir}/grafana.ini":
			ensure  => file,
			content => template("grafana/grafana.ini.erb"),
			owner   => "root",
			group   => "grafana",
			mode    => 0640,
			require => Package["grafana"],
			notify => Service["grafana-server"];
	}

}

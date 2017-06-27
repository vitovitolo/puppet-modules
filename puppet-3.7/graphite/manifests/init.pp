class graphite(
	$config_dir = "/etc/graphite",
	$lib_dir = "/var/lib/graphite/whisper",
	$root_dir = "/usr/share/graphite-web",
	$log_dir = "/var/log/graphite",
	$secret_key = "41778093331572316735",
	$retentions = "1min:30d,10min:90d,60min:180d",
	
	$check_condition = "true",
	$check_hostname = "",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",

) {
	include apache
	$domain = get_env_dnsdomain("$environment")
	$storage_dir = "${lib_dir}/whisper"

	apache::site {"graphite-web":
		enabled  => true,
		ip       => "0.0.0.0",
		port     => 80,
		template => "graphite/apache_site_graphite.erb",
	}

	package {"libapache2-mod-wsgi":
			ensure         => installed,
	        	require        => [Exec["apt-get-update"],Package["apache2"]],
			notify         => Service["apache2"];
		["graphite-carbon","graphite-web"]:
			ensure => installed,
	        	require => Exec["apt-get-update"];
	}
	exec {"/usr/sbin/a2enmod wsgi":
		unless => "/usr/sbin/a2query -m wsgi",
		require => Package["apache2"],
	}
	exec {"/usr/sbin/a2enmod headers":
		unless => "/usr/sbin/a2query -m headers",
		require => Package["apache2"],
	}

	service {"carbon-cache":
		ensure => running,
		require => Package["graphite-carbon"],
	}


	file {"/etc/default/graphite-carbon":
			content => "CARBON_CACHE_ENABLED=true",
			notify => Service["carbon-cache"];
		"${log_dir}":
			ensure  => directory,
			owner   => "_graphite",
			group   => "_graphite",
			require => [Package["apache2"],Package["graphite-carbon"]];

		#Graphite-web configuration
		"${config_dir}/local_settings.py":
			ensure  => file,
			content => template("graphite/local_settings.py.erb"),
			owner   => "root",
			group   => "root",
			mode    => 0644,
			require => [Package["apache2"], Package["libapache2-mod-wsgi"],Package["graphite-web"]],
			notify  => Service["apache2"];

		"${lib_dir}/whisper":
			ensure  => directory,
			owner   => "_graphite",
			group   => "_graphite",
			mode    => 0775,
			require => [Package["apache2"], Package["libapache2-mod-wsgi"],Package["graphite-carbon"]];
		"/etc/carbon":
			ensure  => directory,
			mode    => 0775,
			require => Package["graphite-carbon"];
		"/etc/carbon/carbon.conf":
			ensure  => file,
			content => template("graphite/carbon.conf.erb"),
			owner   => "root",
			group   => "root",
			mode    => 0644,
			require => File["/etc/carbon"],
			notify  => Service["carbon-cache"];
		"/etc/carbon/storage-schemas.conf":
			ensure  => file,
			content => template("graphite/storage-schemas.conf.erb"),
			owner   => "root",
			group   => "root",
			mode    => 0644,
			require => File["/etc/carbon"],
			notify  => Service["carbon-cache"];
	}

}

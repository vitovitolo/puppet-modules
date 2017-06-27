class graphite {
	package {["statsd", "graphite-carbon", "graphite-web", "apache2", "libapache2-mod-wsgi" ]:
	}

	file {
		"/etc/default/graphite-carbon":
			content => "CARBON_CACHE_ENABLED=true
",
			notify => Service["carbon-cache"];

		"/etc/apache2/sites-enabled/apache2-graphite.conf":
			ensure  => file,
			content => template("graphite/apache2-graphite.conf"),
			require => [Package["apache2"], Package["libapache2-mod-wsgi"]],
			notify  => Service["apache2"];

		"/etc/apache2/sites-enabled/000-default":
			ensure => absent,
			require => Package["apache2"],
			notify  => Service["apache2"];

		"/var/log/graphite":
			ensure  => directory,
			owner   => "_graphite",
			group   => "_graphite",
			require => Package["apache2"];

		"/etc/graphite/local_settings.py":
			ensure  => file,
			content => template("graphite/local_settings.py.erb"),
			owner   => "root",
			group   => "root",
			mode    => 0644,
			require => [Package["apache2"], Package["libapache2-mod-wsgi"]],
			notify  => Service["apache2"];

		"/var/lib/graphite/storage":
			ensure  => directory,
			owner   => "_graphite",
			group   => "_graphite",
			mode    => 0775,
			require => [Package["apache2"], Package["libapache2-mod-wsgi"]];

		"/var/lib/graphite/storage/rrd":
			ensure  => directory,
			owner   => "_graphite",
			group   => "_graphite",
			mode    => 0775,
			require => [Package["apache2"], Package["libapache2-mod-wsgi"], File["/var/lib/graphite/storage"]];
	}

	service {
		"carbon-cache":
			ensure => running;
		"apache2":
			ensure  => running,
			require => File["/var/log/graphite"]
	}
}

class logstash(
	$config_template = '',
	$config_patterns = '',
){
	include java8

	package {"logstash":
		ensure => installed
	}

	service {"logstash":
		ensure => running
	}

	if $config_template {
		file {"/etc/logstash/conf.d/logstash.conf":
			ensure => file,
			owner => logstash,
			group => logstash,
			content => template($config_template),
			notify => Service['logstash'],
			require => Package['logstash'],
		}
	}
	if $config_patterns {
		file {"/etc/logstash/conf.d/patterns":
			ensure => directory,
			owner => logstash,
			group => logstash,
		}
		file {"/etc/logstash/conf.d/patterns/custom_patterns":
			ensure => file,
			owner => logstash,
			group => logstash,
			content => template($config_patterns),
			notify => Service['logstash'],
			require => [Package['logstash'],File["/etc/logstash/conf.d/patterns"]],
		}
	}
}

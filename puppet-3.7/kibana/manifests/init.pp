class kibana (
    $config_template = "kibana/kibana.yml.erb",
    $bind_ip = "0.0.0.0",
    $bind_port = "5601",
    $elasticsearch_url = "http://localhost:9200",
    $node_max_old_space_size = "100",

    $accept = true,
    $allow_only_from = "",
    $accept_condition = "",

){
    include java
    include apt::wartortle

    package {"kibana":
        ensure => installed,
        require => Exec["apt-get-update"],
    }

    file {
	    "/etc/company/kibana":
	        ensure => directory,
        	mode => 0755;
	    "/etc/company/kibana/kibana.yml":
        	ensure => file,
	        mode => 0644,
        	content => template($config_template),
	        require => File["/etc/company/kibana"],
        	notify => Service["kibana"];
	    "/opt/kibana/config/kibana.yml":
        	ensure => link,
	        target => "/etc/company/kibana/kibana.yml",
        	notify => Service["kibana"],
	        require => [File["/etc/company/kibana/kibana.yml"], Package["kibana"]];
	    "/opt/kibana/bin/kibana":
        	ensure => file,
	        content => template("kibana/bin_kibana.erb"),
        	notify => Service["kibana"],
	        require => [File["/etc/company/kibana/kibana.yml"], Package["kibana"]];
	    "/var/log/kibana":
	        ensure => directory,
        	mode => 0755;
    }

	serviced {"kibana":
		description     => "Launch Kibana",
		ensure          => running,
		command         => "/opt/kibana/bin/kibana",
		pwd             => "/opt/kibana/bin",
		check_condition => $check_condition,
		check_hostname  => $check_hostname,
		require => [
			Package["kibana"],
			File["/opt/kibana/config/kibana.yml"]			
		];
	}
}

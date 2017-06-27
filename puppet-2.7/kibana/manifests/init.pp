class kibana (
    $config_template = "kibana/kibana.yml.erb"
){
    include java8

    package {"kibana":
        ensure => installed
    }

    file {
    "/etc/company/kibana":
        ensure => directory,
        mode => 0755;
    "/etc/company/kibana/kibana.yml":
        ensure => file,
        mode => 0644,
        content => template($config_template);
    "/opt/kibana-4.1.2-linux-x64/config/kibana.yml":
        ensure => link,
        target => "/etc/company/kibana/kibana.yml",
        notify => Service["kibana"],
        require => [File["/etc/company/kibana/kibana.yml"], Package["kibana"]];
    }

	serviced::service {
	"kibana":
		command => './kibana',
		user => nobody,
		group => nogroup,
		pwd => '/opt/kibana-4.1.2-linux-x64/bin',
		monitoring => $monitoring,
		logger_facility => "daemon",
		require => [
			Package["kibana"],
            File["/opt/kibana-4.1.2-linux-x64/config/kibana.yml"],
		];
	}
}

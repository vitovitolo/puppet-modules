class elasticsearch(
    $cluster_name = "elasticsearch",
    $cluster_nodes = ["localhost"],
    $bind_addr = "0.0.0.0",
    $bind_port = "9200",
    $heap_size = "1g",
    $rack_name = "",
    $zone_name = "",
    $http_cors = false,
    $number_of_shards = "50",
    $number_of_replicas = "1",

    $accept = true,
    $allow_only_from = "",
    $accept_condition = "",

    $check_command = "",
    $check_condition = "true",

) {
    include java
    include apt::wartortle

    package {"elasticsearch":
        ensure => installed,
            require => Exec["apt-get-update"]
    }
    file {
    "/etc/elasticsearch/elasticsearch.yml":
        ensure => file,
        notify => Service["elasticsearch"],
        content => template("elasticsearch/elasticsearch.yml.erb"),
        require => Package["elasticsearch"];
    "/etc/elasticsearch/logging.yml":
        ensure => file,
        notify => Service["elasticsearch"],
        content => template("elasticsearch/logging.yml.erb"),
        require => Package["elasticsearch"];
    "/etc/default/elasticsearch":
        ensure => file,
        notify => Service["elasticsearch"],
        content => template("elasticsearch/default_elasticsearch.erb"),
        require => Package["elasticsearch"];
    "/usr/local/bin/elasticsearch-purge-index":
        ensure  => file,
        mode    => 750,
        owner   => "root",
        content => template("elasticsearch/elasticsearch_purge_index.sh.erb"),
        require => Package["elasticsearch"];
    }
    service {"elasticsearch":
        ensure => running,
        require => File[
            "/etc/elasticsearch/elasticsearch.yml",
            "/etc/elasticsearch/logging.yml"],
    }
    exec {"elasticsearch-update-rc":
        command => "update-rc.d elasticsearch defaults",
        path    => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        unless  => "ls /etc/rc?.d/S??elasticsearch",
        require => Package["elasticsearch"],
        before  => Service["elasticsearch"],
    }
    exec {"elasticsearch-enable":
        command => "systemctl enable elasticsearch.service",
        path    => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        unless  => "systemctl is-enabled elasticsearch.service",
        require => Package["elasticsearch"],
        before  => Service["elasticsearch"],
    }
}

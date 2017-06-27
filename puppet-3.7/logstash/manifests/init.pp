class logstash(
    $config_patterns = '',
    $udp_bind_port = "5514",
    $tcp_bind_port = "5514",
    $elasticsearch_cluster_name = "",
    $elasticsearch_cluster_url = "",

    $accept = true,
    $allow_only_from = "",
    $accept_condition = "",

    $check_command = "",
    $check_condition = "true",
){
    include java
    include apt::wartortle

    package {"logstash":
        ensure => installed
    }

    service {"logstash":
        ensure => running
    }

    exec {"logstash-update-rc":
        command => "update-rc.d logstash defaults",
        path    => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        unless  => "ls /etc/rc?.d/S??logstash",
        require => Package["logstash"],
        before  => Service["logstash"],
    }
    if $config_patterns {
        file {"/etc/logstash/conf.d/patterns":
            ensure => directory,
            owner  => logstash,
            group  => logstash,
        }
        file {"/etc/logstash/conf.d/patterns/custom_patterns":
            ensure  => file,
            owner   => logstash,
            group   => logstash,
            content => template($config_patterns),
            notify  => Service['logstash'],
            require => [Package['logstash'],File["/etc/logstash/conf.d/patterns"]],
        }
    }
}

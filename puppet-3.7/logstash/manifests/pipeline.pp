define logstash::pipeline
(
    $config_template = "${name}_logstash.conf.erb",
    $extra_bind_port = '',
    $accept = true,
    $allow_only_from = '',
    $accept_condition = '',
)
{
    include logstash
    $udp_bind_port = getparam(Class['logstash'],'udp_bind_port')
    $tcp_bind_port = getparam(Class['logstash'],'tcp_bind_port')
    $elasticsearch_cluster_name = getparam(Class['logstash'],'elasticsearch_cluster_name')
    $elasticsearch_cluster_url = getparam(Class['logstash'],'elasticsearch_cluster_url')

    file {"/etc/logstash/conf.d/${name}.conf":
        ensure  => file,
        owner   => logstash,
        group   => logstash,
        content => template("logstash/${config_template}"),
        notify  => Service['logstash'],
        require => Package['logstash'],
    }

}

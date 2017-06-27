define elasticsearch::purge_index
(
    $index_name = $name,
    $hostname = hiera("elasticsearch::purge_index::${name}::hostname", "localhost"),
    $days_keep = hiera("elasticsearch::purge_index::${name}::days_keep","30"),
)
{
    include elasticsearch

    cronjob {"elasticsearch-purge-index-${index_name}":
        command => "/usr/local/bin/elasticsearch-purge-index ${hostname} ${index_name} ${days_keep} | /usr/bin/logger -p local0.info -t elasticsearch-purge-index",
        minute  => "*/5",
        require => File["/usr/local/bin/elasticsearch-purge-index"],
    }
}

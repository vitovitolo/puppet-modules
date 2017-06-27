define diamond::collector
(
	$collector_name = $name,
	$path_suffix = "",

	$haproxy_name = "",
)
{
	file {
		"/etc/diamond/collectors/${collector_name}Collector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/${collector_name}Collector.erb"),
			require => File["/etc/diamond/collectors"];
	}
}

define grafana::dashboard
(
	$template = $name,

	$haproxy_name = "",
	$haproxy_proxyregex = "*",
	$haproxy_backendregex = "*",
)
{
	include grafana::create_dashboard
	
	exec {"create-dashboard-${template}":
		command     => "/usr/local/bin/create-grafana-dashboard /var/lib/grafana/templates/dashboard_${template}.json",
		path        => ["/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin"],
		refreshonly => true,
		require     => File["/usr/local/bin/create-grafana-dashboard"],
	}

	# Create array from stringify facts due to puppet 2.2 version
	$hwinfo_cpus = split($hwinfo_cpus_string,',')
	$hwinfo_networkifaces = split($hwinfo_networkifaces_string,',')
	$hwinfo_mountpoints = split($hwinfo_mountpoints_string,',')
	$hwinfo_physicaldisks = split($hwinfo_physicaldisks_string,',')

	if $hwinfo_cpus != [] and $hwinfo_networkifaces != [] and $hwinfo_mountpoints != []  and $hwinfo_physicaldisks != []  {

		file {	"/var/lib/grafana/templates/dashboard_${template}.json":
				ensure  => file,
				mode    => 0640,
				content => template("grafana/dashboard_${template}.erb"),
				audit   => content,
				notify  => Exec["create-dashboard-${template}"],
				require => File["/var/lib/grafana/templates"];
		}
	}
}

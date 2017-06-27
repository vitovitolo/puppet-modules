define grafana::dashboard
(
	$template = $name,
	$environment = hiera("grafana::dashboard::${name}::environment", "wartortledev"),
)
{
	include grafana::create_dashboard

	exec {"create-dashboard":
		command     => "/usr/local/bin/create-grafana-dashboard /var/lib/grafana/templates/dashboard_${template}.json",
		path        => ["/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin"],
		refreshonly => true,
		require     => [File["/usr/local/bin/create-grafana-dashboard"],File["/var/lib/grafana/templates/dashboard_${template}.json"]],
	}
	file {
		"/var/lib/grafana":
			ensure  => directory,
			mode    => 0755;
		"/var/lib/grafana/templates":
			ensure  => directory,
			mode    => 0755,
			require => File["/var/lib/grafana"];
	}
	# check for facter to be defined
	if $hwinfo_cpus != [] and $hwinfo_networkifaces != [] and $hwinfo_mountpoints != []  and $hwinfo_physicaldisks != []  {
		file { "/var/lib/grafana/templates/dashboard_${template}.json":
				ensure  => file,
				mode    => 0640,
				content => template("grafana/dashboard_${template}.erb"),
				audit   => content,
				notify  => Exec["create-dashboard"],
				require => File["/var/lib/grafana/templates"];
		}
	}
}

class grafana::create_dashboard
(
	$grafana_hostname = "grafana.example.com",
	$grafana_api_key = "xxxxx",
)
{
	file {
		"/usr/local/bin/create-grafana-dashboard":
			ensure  => file,
			mode    => 0750,
			content => template("grafana/create-grafana-dashboard.erb");
		"/var/lib/grafana":
			ensure  => directory,
			mode    => 0755;
		"/var/lib/grafana/templates":
			ensure  => directory,
			mode    => 0755,
			require => File["/var/lib/grafana"];
	}
}

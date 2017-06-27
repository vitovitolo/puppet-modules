class grafana::create_dashboard
(
	$grafana_hostname = "",
	$grafana_api_key = "",
)
{
	file {
		"/usr/local/bin/create-grafana-dashboard":
			ensure  => file,
			mode    => 0750,
			content => template("grafana/create-grafana-dashboard.erb");
	}
}

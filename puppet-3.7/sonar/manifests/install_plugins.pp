define sonar::install_plugins
(
	$list = hiera("sonar::install_plugins::list",""),
)
{
	if $list != "" {
		sonar::plugin{ $list: }
	}
}

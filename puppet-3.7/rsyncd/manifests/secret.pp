define rsyncd::secret
(
	$module,
	$user,
	$password,
)
{
	concat::fragment{"rsyncd.secrets.$module.500-$name":
		target  => "/etc/rsyncd.secrets.${module}",
		content => template("rsyncd/rsyncd.secrets.erb"),
		order   => "500",
	}
}

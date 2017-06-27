define squid::acl
(
	$acl_name = "${name}",
	$acl_src = [],
	$acl_order = "50",
	$acl_urlregex = "",
	$acl_regexfile = "",
	$acl_regexfilecontent = "",
)
{
	file {"/etc/squid/acl.d/${acl_order}_acl_${acl_name}.conf":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0600,
		content => template("squid/acl_custom.conf.erb"),
		require => [Package["squid"],File["/etc/squid/acl.d"]],
		notify  => Service["squid"],
	}
	if $acl_regexfile {
		file {"/etc/squid/regex.d/${acl_regexfile}":
			ensure  => file,
			owner   => "root",
			group   => "root",
			mode    => 0600,
			content => $acl_regexfilecontent,
			require => [Package["squid"],File["/etc/squid/regex.d"]],
			notify  => Service["squid"],
		}
	}
}

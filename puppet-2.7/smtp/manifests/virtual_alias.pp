define smtp::virtual_alias
(
	$source = "$name",
	$target,
)
{
	concat::fragment{"/etc/postfix/virtual_alias-${name}":
		target  => "/etc/postfix/virtual_alias",
		content => "$source $target
",
		order   => "999",
	}
}

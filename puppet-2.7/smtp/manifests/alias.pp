define smtp::alias
(
	$source = "$name",
	$target,
)
{
	concat::fragment{"/etc/aliases-${name}":
		target  => "/etc/aliases",
		content => "$source $target
",
		order   => "999",
	}
}

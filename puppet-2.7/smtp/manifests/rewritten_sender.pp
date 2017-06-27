define smtp::rewritten_sender
(
	$source = "$name",
	$target = "$name@example.com",
)
{
	concat::fragment{"/etc/postfix/generic-${name}":
		target  => "/etc/postfix/generic",
		content => "$source $target
",
		order   => "000",
	}
}

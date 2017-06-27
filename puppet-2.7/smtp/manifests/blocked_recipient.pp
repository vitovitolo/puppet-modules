define smtp::blocked_recipient
(
	$target = "$name",
	$action = "REJECT",
)
{
	concat::fragment{"/etc/postfix/recipient_block-${name}":
		target  => "/etc/postfix/recipient_block",
		content => "$target $action
",
		order   => "000",
	}
}

define smtp::blocked_recipient
(
	$target = "$name",
	$action = "REJECT",
)
{
	smtp::hash_file_entry {"blocked_recipient:$name":
		item      => $source,
		value     => $action,
		hash_file => "/etc/postfix/recipient_block",
	}
}

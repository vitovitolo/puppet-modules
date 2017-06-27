define smtp::rewritten_sender
(
	$source = "$name",
	$target = "$name@example.com",
)
{
	smtp::hash_file_entry {"rewritten_sender:$name":
		item      => $source,
		value     => $target,
		hash_file => "/etc/postfix/generic",
	}
}

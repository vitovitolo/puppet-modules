define smtp::transport
(
	$source = "$name",
	$target,
)
{
	smtp::hash_file_entry {"transport:$name":
		item      => $source,
		value     => $target,
		hash_file => "/etc/postfix/transport",
	}
}

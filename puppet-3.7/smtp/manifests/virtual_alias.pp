define smtp::virtual_alias
(
	$source = "$name",
	$target,
)
{
	smtp::hash_file_entry {"virtual_alias:$name":
		item      => $source,
		value     => $target,
		hash_file => "/etc/postfix/virtual_alias",
	}
}

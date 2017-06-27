define smtp::virtual_alias_regexp
(
	$source = "$name",
	$target,
)
{
	smtp::hash_file_entry {"virtual_alias_regexp:$name":
		item      => $source,
		value     => $target,
		hash_file => "/etc/postfix/virtual_alias_regexp",
	}
}

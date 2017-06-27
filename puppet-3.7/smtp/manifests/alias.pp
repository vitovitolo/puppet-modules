define smtp::alias
(
	$source = "$name",
	$target,
)
{
	smtp::hash_file_entry {"alias:$name":
		item      => $source,
		value     => $target,
		hash_file => "/etc/aliases",
	}
}

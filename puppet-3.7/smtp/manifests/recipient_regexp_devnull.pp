define smtp::recipient_regexp_devnull
(
	$virtual_alias = $name,
	$target = "devnull",
)
{
	smtp::virtual_alias_regexp{$virtual_alias:
		target => "${target}",
	}
}

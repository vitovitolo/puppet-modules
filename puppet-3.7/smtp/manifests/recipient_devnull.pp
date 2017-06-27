define smtp::recipient_devnull
(
	$virtual_alias = $name,
	$target = "devnull",
)
{
	smtp::virtual_alias{$virtual_alias:
		target => "${target}",
	}
}

define smtp::hash_file_entry
(
	$item = "$name",
	$value,
	$hash_file,
)
{
	concat::fragment{"smtp::hash_file_entry-${name}":
		target  => $hash_file,
		content => template("smtp/hash_file_entry.erb"),
		order   => "999",
	}
}

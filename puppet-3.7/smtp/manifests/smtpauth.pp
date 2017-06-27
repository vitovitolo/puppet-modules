define smtp::smtpauth
(
	$host = "$name",
	$username,
	$password,
)
{
	smtp::hash_file_entry {"smtpauth:$name":
		item      => $host,
		value     => "${username}:${password}",
		hash_file => "/etc/postfix/sasl_passwd",
	}
}

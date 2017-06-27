class hwinfo
(
)
{
	file {"/usr/local/sbin/hwinfo":
		ensure  => absent,
	}
}

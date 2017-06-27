class hwinfo
(
	$hwinfo_array = ["cpus","networkifaces","physicaldisks","mountpoints"],
)
{
	hwinfo::facter{$hwinfo_array: }
}

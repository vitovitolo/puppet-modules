define hwinfo::facter
(
)
{

	file {"/usr/lib/ruby/vendor_ruby/facter/hwinfo_${name}.rb":
		ensure  => file,
		mode    => 0644,
		owner   => "root",
		group   => "root",
		content => template("hwinfo/hwinfo_${name}.rb.erb"),
	}
}

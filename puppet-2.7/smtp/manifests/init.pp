class smtp
(
	$only_loopback = true,
	$relay_to = "smtp.example.com",
	$relay_domains = ["example.com"],
	$mynetworks = [],
	$myhostname = "$hostname",
	$promiscuous_relay = false,
	$queue_lifetime = "6h",
	$localmailblackhole = "root",
	$trashrootmail = true,
)
{
	package {"postfix":
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
	service {"postfix":
		ensure  => running,
		require => Package["postfix"],
	}
	file {"/etc/postfix/main.cf":
		ensure => file,
		owner  => "root",
		group  => "root",
		mode => 0644,
		require => Package["postfix"],
		notify  => Service["postfix"],
		content => template("smtp/main.cf.erb"),
	}
	smtp::hash_file {"/etc/aliases":
	}
	smtp::alias{"postmaster":
		target => "root",
	}
	if $trashrootmail {
		smtp::alias{"root":
			target => "/dev/null",
		}
	}
	smtp::hash_file {"/etc/postfix/virtual_alias":
	}
	if $localmailblackhole != "" {
		smtp::virtual_alias{"@$hostname":
			target => "$localmailblackhole",
		}
		smtp::virtual_alias{"@localhost":
			target => "$localmailblackhole",
		}
	}
	smtp::hash_file {"/etc/postfix/generic":
	}
	smtp::hash_file {"/etc/postfix/recipient_block":
	}
}

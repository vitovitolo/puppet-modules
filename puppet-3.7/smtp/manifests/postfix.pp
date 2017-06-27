class smtp::postfix
(
	$myhostname = "$hostname",
	$smtp_helo_name,
	$mynetworks = [],
	$relay_domains = ["example.com"],
	$relay_auth = false,
	$relay_user = "",
	$relay_password = "",
	$relay_tls = false,
	$relayhost = "smtp.example.com",
	$interfaces,
	$allow_any_destination = false,
	$queue_lifetime = "6h",
	$localmailblackhole = "root",
	$root_public_address = "",
	$trashrootmail = true,
	$recipient_devnull = [],
	$recipient_regexp_devnull = [],

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",

	$check_condition = "true",
	$check_hostname = "",
)
{
	include smtp::remove_exim
	package {"postfix":
		ensure  => installed,
		require => Exec["apt-get-update"],
	}
	service {"postfix":
		ensure    => "running",
		require   => Package["postfix"],
	}
	concat {"/etc/postfix/main.cf":
		ensure => present,
		owner  => "root",
		group  => "root",
		mode => 0644,
		require => Package["postfix"],
		notify  => Service["postfix"],
	}
	concat::fragment {"postfix-main-00-main":
		target  => "/etc/postfix/main.cf",
		content => template("smtp/postfix.main.cf.erb"),
		order   => "00",
	}
	concat::fragment {"postfix-main-01-relay":
		target  => "/etc/postfix/main.cf",
		content => template("smtp/postfix.relay.main.cf.erb"),
		order   => "01",
	}
	smtp::hash_file {"/etc/aliases":
		update_cmd => "postalias",
	}
	smtp::hash_file {"/etc/postfix/virtual_alias": }
	smtp::hash_file {"/etc/postfix/virtual_alias_regexp": }
	smtp::hash_file {"/etc/postfix/transport": }
	smtp::hash_file {"/etc/postfix/generic": }
	smtp::hash_file {"/etc/postfix/recipient_block": }
	smtp::hash_file {"/etc/postfix/sasl_passwd": }
	if $relay_auth {
		smtp::smtpauth {$relayhost:
			username => $relay_user,
			password => $relay_password,
		}
	}
	smtp::alias {"postmaster:":
		target => "devnull",
	}
	if $trashrootmail {
		smtp::alias {"devnull:":
			target => "/dev/null",
		}
	}
	if $root_public_address != "" {
		smtp::rewritten_sender{"root":
			target => "$root_public_address",
		}
	}
	if $localmailblackhole != "" {
		smtp::transport{"localhost":
			target => "discard:",
		}
		smtp::transport{"localdomain":
			target => "discard:",
		}
		smtp::transport{"localhost.localdomain":
			target => "discard:",
		}
	}
	if $recipient_devnull != undef {
		smtp::recipient_devnull{$recipient_devnull:}
	}
	if $recipient_regexp_devnull != undef {
		smtp::recipient_regexp_devnull{$recipient_regexp_devnull:}
	}
}

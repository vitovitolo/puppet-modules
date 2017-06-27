class rsyncd
(
	$ip = "0.0.0.0",
	$port = "873",

	$accept = true,
	$allow_only_from = "",
	$accept_condition = "",

	$check_condition = "true",
	$check_hostname = "",

	$modules = undef,
)
{
	include ssh
	concat {"/etc/rsyncd.conf":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0644,
		require => Package ["rsync"],
		notify  => Service ["rsync"],
	}
	concat::fragment {"rsyncd.conf-00-header":
		target  => "/etc/rsyncd.conf",
		content => template("rsyncd/rsyncd.header.conf.erb"),
		order   => "000",
	}
	include serviced::setup
	$systemctl_enabled = getparam(Class["serviced::setup"], "systemctl_enabled")
	if $systemctl_enabled {
		exec {"install-rsync-service":
			command => "systemctl enable rsync",
			path    => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
			creates => "/etc/systemd/system/multi-user.target.wants/rsync.service",
			require => Package["rsync"],
			before  => Service["rsync"],
		}
	}
	service {"rsync":
		ensure  => running,
		require => Package["rsync"],
	}
	concat {"/usr/local/sbin/ensure_rsync_directories":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0750,
	}
	concat::fragment {"ensure_rsync_directories_header":
		target  => "/usr/local/sbin/ensure_rsync_directories",
		order   => "000",
		content => template("concat/bash_header.erb"),
	}
	cronjob {"ensure_rsync_directories":
		command => "/usr/local/sbin/ensure_rsync_directories",
	}
	concat {"/etc/default/rsync":
		ensure  => present,
		owner   => "root",
		group   => "root",
		require => Package["rsync"],
		notify  => Service["rsync"],
	}
	concat::fragment {"rsync-default-000-header":
		target => "/etc/default/rsync",
		order  => "000",
		content => template("rsyncd/rsyncd.default.erb"),
	}
	if $modules {
		create_resources(rsyncd::module, $modules)
	}
}

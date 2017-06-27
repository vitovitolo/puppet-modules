define rsyncd::module 
(
	$path = "/tmp",
	$max_connections = "1",
	$timeout = "60",
	$auth_user = "",
	$auth_passwd = "",
	$secrets_file = "template('rsyncd/rsyncd.secrets.erb')",
	$secrets_file_path = "/etc/rsyncd.secrets_${name}",
	$uid = "",
	$gid = "",
	$read_only = false,
	$write_only = true,
	$list = true,
	$prexfer_exec = "",
	$postxfer_exec = "",
	$rsyncd_content = "",
	$munge_symlinks = "false",
	$hosts_allow = "",
	$in_chmod = "",
	$comment = "Rsync ${name} module",

)
{
	include rsyncd::setup
	if $path != "" {
		file {"$path":
			ensure => directory,
			owner  => $uid,
			group  => $gid,
		}
	}
	if $uid != "" {
		$require_user = User[$uid]
	} else {
		$require_user = []
	}
	if $gid != "" {
		$require_group = Group[$gid]
	} else {
		$require_group = []
	}
	if $postxfer_exec {
		file {"/usr/local/bin/postxfer-${name}.sh":
			ensure  => file,
			mode    => 750,
			owner	=> "root",
			group 	=> "root",
			source => $postxfer_exec,
		}
		$postxfer_exec_path = "/usr/local/bin/postxfer-${name}.sh"
	}
	if $prexfer_exec {
		file {"/usr/local/bin/prexfer-${name}.sh":
			ensure  => file,
			mode    => 750,
			owner	=> "root",
			group 	=> "root",
			source => $prexfer_exec,
		}
		$prexfer_exec_path = "/usr/local/bin/prexfer-${name}.sh"
	}
	file {"/etc/rsyncd.secrets_${name}":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0600,
		content => $secrets_file
	}
	concat::fragment{"rsyncd.${name}.conf":
		target  => "/etc/rsyncd.conf",
		order   => "100",
		content => template("rsyncd/rsyncd.module.conf.erb"),
		require => [$require_user,$require_group]
	}
}

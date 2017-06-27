class deploy
(
	$rsyncd_user,
	$rsyncd_password,
	$server = "artifacts",
	$protocol = "http",
	$orchestrator = true,
	$deploy_uid,
	$deploy_gid,
	$backup_count,
	$show_deployed_versions_template = "deploy/show_deployed_versions.sh.erb",
	$artifacts = undef,
)
{
	$deploy_path = "/var/lib/deploy"
	$var_run_path="/var/run/deploy"
	file {"${deploy_path}":
		ensure  => directory,
		owner   => "root",
		group   => "deploy",
		mode    => 0750,
		require => Group["deploy"],
	}
	file {"${deploy_path}/tmp":
		ensure  => link,
		target  => "/tmp",
		require => File["${deploy_path}"],
	}
	file {"${deploy_path}/bin":
		ensure  => directory,
		require => File["${deploy_path}"],
	}
	file {"${deploy_path}/deployed":
		ensure  => link,
		target  => "/etc/company/artifacts/deployed",
		require => [File["${deploy_path}"],File["/etc/company/artifacts/deployed"]],
	}
	file {"${deploy_path}/versions":
		ensure  => link,
		target  => "/etc/company/artifacts/versions",
		require => [File["${deploy_path}"],File["/etc/company/artifacts/versions"]],
	}
	file {["${deploy_path}/backup", "${deploy_path}/local"]:
		ensure => directory,
		mode   => 0750,
		owner  => "root",
		group  => "deploy",
		require => File["${deploy_path}"],
	}
	file {"/var/log/company":
		ensure => directory,
		owner  => "root",
		group  => "root",
		mode   => 0755,
	}
	file {"/etc/company/artifacts":
		ensure  => directory,
		mode    => 0755,
		owner   => "root",
		group   => "root",
		require => File["/etc/company"],
	}
	file {"/etc/company/artifacts/deployed":
		ensure  => directory,
		mode    => 0755,
		owner   => "root",
		group   => "root",
		require => File["/etc/company/artifacts"],
	}
	file {"/etc/company/artifacts/versions":
		ensure  => directory,
		mode    => 0755,
		owner   => "root",
		group   => "root",
		require => File["/etc/company/artifacts"],
	}
	user {"deploy":
		ensure  => present,
		uid     => $deploy_uid,
		gid     => $deploy_gid,
		shell   => "/bin/bash",
		home    => "${deploy_path}",
		require => Group["deploy"],
	}
	group {"deploy":
		ensure => present,
		gid    => $deploy_gid,
	}
	sudo::sudoersfile {"deploy": }
	sudo::sudoersfileline {["${deploy_path}/bin/deploy.sh","/usr/local/bin/deploy"]:
		user    => "%deploy",
		file    => "deploy",
		require => File["${deploy_path}/bin/deploy.sh"],
	}
	file {"${deploy_path}/bin/deploy.sh":
		ensure  => file,
		mode    => 0740,
		owner   => "root",
		group   => "deploy",
		content => template("deploy/deploy.sh.erb"),
		require => File["${deploy_path}/bin"],
	}
	file {"${deploy_path}/bin/show_deployed_versions.sh":
		ensure  => file,
		mode    => 0755,
		owner   => "root",
		group   => "deploy",
		content => template($show_deployed_versions_template),
		require => File["${deploy_path}/bin"],
	}
	file {"/etc/bash_completion.d/deploy":
		ensure  => file,
		mode    => 0644,
		owner   => "root",
		group   => "root",
		content => template("deploy/deploy_completion.erb"),
		require => Package["bash-completion"],
	}
	file {"/usr/local/bin/show_deployed_versions":
		ensure => link,
		target => "${deploy_path}/bin/show_deployed_versions.sh",
	}
	file {"/usr/local/bin/deploy":
		ensure => link,
		target => "${deploy_path}/bin/deploy.sh",
	}
	file {"${deploy_path}/bin/prexfer.sh":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0750,
		content => template("deploy/prexfer.sh.erb"),
		require => File["${deploy_path}/bin"],
	}
	file {"${deploy_path}/bin/postxfer.sh":
		ensure  => file,
		owner   => "root",
		group   => "root",
		mode    => 0750,
		content => template("deploy/postxfer.sh.erb"),
		require => File["${deploy_path}/bin"],
	}
	rsyncd::module {"deploy":
		path          => "$var_run_path",
		uid           => "deploy",
		gid           => "deploy",
		prexfer_exec  => "${deploy_path}/bin/prexfer.sh",
		postxfer_exec => "${deploy_path}/bin/postxfer.sh",
		require       => [File["${deploy_path}/bin/prexfer.sh"],File["${deploy_path}/bin/postxfer.sh"]],
	}
	if $rsyncd_user != "" {
		rsyncd::secret {"deploy_user":
			module       => "deploy",
			user         => $rsyncd_user,
			password     => $rsyncd_password,
		}
	}
	if $artifacts {
		deploy::artifact{$artifacts: }
	}
}

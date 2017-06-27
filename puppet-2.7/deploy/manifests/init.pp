class deploy
(
	$deploy_path = "/root",
	$deploy_artifacts = [],
	$deploy_build_stage = "artifacts/stable",
	$deploy_cfg_file = "/etc/company/artifacts/deploy.cfg",
	$artifact_server = "artifacts",
	$auto_deploy = false,
	$artifacts_versions = [],
)
{
	user {"deploy":
		ensure  => present,
		uid     => 10999,
		gid     => 10999,
		shell   => "/bin/bash",
		require => Group["deploy"],
	}
	group {"deploy":
		ensure => present,
		gid    => 10999,
	}
	file {"/etc/sudoers.d/deploy":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0440,
		content => template("deploy/deploy_sudoers.erb"),
	}

	file {"${deploy_path}/deploy.sh":
		ensure  => file,
		mode    => 0755,
		content => template("deploy/deploy.sh.erb"),
	}
	file {"${deploy_path}/backup":
		ensure => directory,
		mode   => 0755,
		owner  => "root",
		group  => "root",
	}
	deploy_versions { $deploy_artifacts : 
		artifact_server => $artifact_server
	}
	deploy_url { $deploy_artifacts :
		deploy_build_stage => $deploy_build_stage,
		deploy_path        => $deploy_path,
	}
	if $artifacts_versions {
		deploy_url_link { $artifacts_versions : 
			deploy_path        => $deploy_path,
		}
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

	$check_local_version = hiera("deploy_check_local_version")
	file {"/etc/company/artifacts/deploy.cfg":
		ensure  => file,
		mode    => 0644,
		owner   => "root",
		group   => "root",
		content => template("deploy/deploy.cfg.erb"),
		require => File["/etc/company/artifacts"],
	}

	#Copy to puppet masters the list of artifacts deployed in each server (orchestator purpose)
	$cmd_addartifacts=template("deploy/addartifacts.erb")
	$cmd_addartifacts_result = get_command_result($cmd_addartifacts)

	#This variables are used in auto-deploy script also
	$rsyncd_auth_user = "deploy"
	$rsyncd_secrets_file_path = "/etc/rsyncd.secrets_deploy"

	#Include rsync daemon deploy module
	rsyncd::module {"deploy":
                path              => "/var/run/deploy",
                auth_user         => $rsyncd_auth_user,
                secrets_file      => template("rsyncd.secrets.erb"),
                secrets_file_path => $rsyncd_secrets_file_path,
                uid               => "deploy",
                gid               => "deploy",
                prexfer_exec      => "puppet:///modules/rsyncd/prexfer-deploy.sh",
                postxfer_exec     => "puppet:///modules/rsyncd/postxfer-deploy.sh",
        }

	if $auto_deploy {
		file {"/usr/local/bin/auto-deploy.sh":
			ensure  => file,
			mode    => 0750,
			owner   => "root",
			group   => "root",
			content => template("deploy/auto-deploy.sh.erb"),
		}
		# Deprecated
		#cronjob {"auto-deploy":
		#	command => "/usr/local/bin/auto-deploy.sh | logger -p local0.info -t auto-deploy",
		#	user    => "root",
		#	require => File["/usr/local/bin/auto-deploy.sh"],
		#}
	}

}
define deploy_url
(
	$deploy_build_stage = "artifacts/stable",
	$deploy_path,
)
{
	$build_stage = $deploy_build_stage
	$artifact = $name
	if $artifact != "" {
		file {"${deploy_path}/deploy_url_${artifact}":
			ensure  => file,
			mode    => 0644,
			content => template("deploy/deploy_url_${artifact}.erb"),
		}
	}
}
define deploy_url_link
(
	$deploy_path,
)
{
	if $artifact != "" {
		#To downcase artifact name string
		$artifact_aux = inline_template('<%= @name.downcase %>')
		$artifact = regsubst( $artifact_aux, '_' , '-', 'G')
		file {"${deploy_path}/deploy_url_${name}":
			ensure  => link,
			target => "/etc/company/artifacts/versions/${artifact}",
		}
	}
}
define deploy_versions
(
	$artifact_server = "artifacts"
)
{
  $environment_short = "pro"
	#To downcase artifact name string
	$artifact_aux = inline_template('<%= @name.downcase %>')
	$artifact = regsubst( $artifact_aux, '_' , '-', 'G')
	if $artifact != "" {
		file {"/etc/company/artifacts/versions/${artifact}":
			ensure  => file,
			mode    => 0644,
			content => "http://${artifact_server}/versions/${environment_short}/${artifact}",
			require => File["/etc/company/artifacts"],
		}
	}
}

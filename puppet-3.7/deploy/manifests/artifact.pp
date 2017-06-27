define deploy::artifact
(
	$artifact = $name,
	$protocol = hiera("deploy::artifact::${name}::protocol", hiera("deploy::protocol", "http")),
	$server = hiera("deploy::artifact::${name}::server", hiera("deploy::server", "artifacts")),
	$versions_path = hiera("deploy::artifact::${name}::versions_path", hiera("deploy::artifact::versions_path", "")),
	$orchestrator = hiera("deploy::artifact::${name}::orchestrator", hiera("deploy::orchestrator", true)),
	$old_deploy = false,
	$old_deploy_stage = hiera("deploy::artifact::old_deploy_stage", "artifacts/nightly"),
	$old_deploy_extension = hiera("deploy::artifact::${name}::old_deploy_extension", "war"),
)
{
	include deploy
	$artifact_aux = inline_template("<%=@artifact.downcase%>")
	$artifact_name = regsubst( $artifact_aux, '_' , '-', 'G')
	if $versions_path == "" {
		$env_short = regsubst($environment, "^wartortle", "")
		$versions="versions/$env_short"
	} else {
		$versions=$versions_path
	}
	file {"/etc/company/artifacts/versions/${artifact_name}":
		ensure  => file,
		mode    => 0644,
		require => File["/etc/company/artifacts/versions"],
		content => template("deploy/deploy_versions.erb"),
	}
	if $old_deploy {
		file {"/root/deploy_url_${artifact_name}":
			ensure  => file,
			mode    => 0644,
			content => inline_template("<%=@protocol-%>://<%=@server-%>/<%=@old_deploy_stage-%>/<%=@artifact_name-%>/<%=@name-%>.<%=@old_deploy_extension-%>"),
		}
	}

	if $orchestrator {
		$cmd_add_artifact=template("deploy/add_artifact.erb")
		$cmd_add_artifact_result=get_command_result($cmd_add_artifact)
	}
}

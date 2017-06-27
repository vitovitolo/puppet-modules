class curator
(
	$version = "3.4.1",
	$pypi_url = "http://pypi.example.com:8090/simple",
	$clean_indexes = true,
	$indexes_threshold = "30",
)
{
	exec{"install_curator":
		command => "/usr/bin/pip install elasticsearch-curator==${version} -i  ${pypi_url}",
		unless  => "/usr/bin/pip freeze 2>&1 | /bin/grep  'elasticsearch-curator==$version' >> /dev/null 2>&1",
		user    => "root",
		path    => [ "/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin","/root/bin" ],
		require => Package["python-pip"],
	}
	file {"/usr/local/bin/clean_indexes.sh":
		ensure  => present,
		owner   => "root",
		group   => "root",
		mode    => 0750,
		content => template("curator/clean_indexes.sh.erb"),
	}
	cronjob{"curator_clean_indexes":
		command => "/usr/local/bin/clean_indexes.sh",
		user    => "root",
		hour    => "0",
		require => File["/usr/local/bin/clean_indexes.sh"],
	}

}

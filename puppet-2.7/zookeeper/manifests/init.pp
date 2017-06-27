class zookeeper
(
	$server=false,
	$server_list=["$hostname"],
	$server_id=1,
	$java_pkg = "java",
	$zk_jvm_Xms = "26M",
	$zk_jvm_Xmx = "64M",
	$zk_preAllocSize="1024",
	$zk_autopurge_snapRetainCount = "3",
	$zk_autopurge_purgeInterval = "24",
	$zk_snapCount = "100000",
)
{

	if $server {
		package {"zookeeper":
			ensure  => installed,
			require => [Exec["apt-get-update"],Package["${java_pkg}"]],
		}
		package{"python-zookeeper":
			ensure  => installed,
			require => Package["zookeeper"],
		}
		file {"/opt/zookeeper":
			ensure  => link,
			target  => "/opt/zookeeper-3.4.5/",
			require => Package["zookeeper"],
		}
		file {"/var/lib/zookeeper/myid":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => "0644",
			content => "$server_id",
			require => Package["zookeeper"],
			notify  => Service["zookeeper"],
		}
		file {"/etc/zookeeper":
			ensure  => link,
			target  => "/opt/zookeeper/conf",
			require => Package["zookeeper"],
		}
		$preAllocSize = $zk_preAllocSize
		$autopurge_snapRetainCount = $zk_autopurge_snapRetainCount
		$autopurge_purgeInterval = $zk_autopurge_purgeInterval
		$snapCount = $zk_snapCount
		file {"/opt/zookeeper/conf/zoo.cfg":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => "0644",
			content => template("zookeeper/zoo.cfg.erb"),
			require => Package["zookeeper"],
			notify  => Service["zookeeper"],
		}
		$jvm_Xms = $zk_jvm_Xms
		$jvm_Xmx = $zk_jvm_Xmx
		file {"/opt/zookeeper/conf/java.env":
			ensure  => "file",
			owner   => "root",
			group   => "root",
			mode    => "0644",
			content => template("zookeeper/java.env.erb"),
			require => Package["zookeeper"],
			notify  => Service["zookeeper"],
		}
		service {"zookeeper":
			ensure  => running,
			require => Package["zookeeper"],
		}
	}
}

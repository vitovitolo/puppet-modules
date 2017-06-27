class diamond
(
	$service_state = "running",
	$main_path_suffix = "vm.${environment}",
	$poll_interval = "60",
	$log_level = "INFO",
	$graphite_handler = false,
	$graphite_host = "127.0.0.1",
	$statsd_handler = true,
	$statsd_host = "127.0.0.1",

	$cpu = true,
	$cpu_path_suffix = "",
	$memory = true,
	$memory_path_suffix = "",
	$io = true,
	$io_path_suffix = "",
	$network = true,
	$network_path_suffix = "",
	$diskspace = true,
	$diskspace_path_suffix = "",

)
{
	package {["diamond","python-statsd","python-pkg-resources"]:
		ensure => installed,
        	require => Exec["apt-get-update"]
	}
	file {
		"/etc/diamond":
			ensure => directory,
			require => Package["diamond"];
		"/etc/diamond/diamond.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/diamond.erb"),
			require => File["/etc/diamond"];
		"/etc/diamond/collectors":
			ensure => directory,
			require => File["/etc/diamond"];
	}
	if $cpu {
		file {
		"/etc/diamond/collectors/CPUCollector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/CPUCollector.erb"),
			require => File["/etc/diamond/collectors"];
		}
	}
	if $memory {
		file {
		"/etc/diamond/collectors/MemoryCollector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/MemoryCollector.erb"),
			require => File["/etc/diamond/collectors"];
		}
	}
	if $io {
		file {
		"/etc/diamond/collectors/DiskUsageCollector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/DiskUsageCollector.erb"),
			require => File["/etc/diamond/collectors"];
		}
	}
	if $network {
		file {
		"/etc/diamond/collectors/NetworkCollector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/NetworkCollector.erb"),
			require => File["/etc/diamond/collectors"];
		}
	}
	if $diskspace {
		file {
		"/etc/diamond/collectors/DiskSpaceCollector.conf":
			ensure => file,
			notify => Service["diamond"],
			content => template("diamond/DiskSpaceCollector.erb"),
			require => File["/etc/diamond/collectors"];
		}
	}
	service {"diamond":
		ensure => $service_state,
		require => File[
			"/etc/diamond/diamond.conf"],
	}

}

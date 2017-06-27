define sonar::plugin
(
	$filename = hiera("sonar::plugin::${name}::filename",""),
)
{
	include sonar

	if $filename != "" {
        	urlfile {
	        "/opt/sonar/extensions/plugins/${filename}":
        	    ensure => present,
	            url    => "http://artifacts/binaries/core/sonar_plugins/${filename}",
        	    md5url => "http://artifacts/binaries/core/sonar_plugins/${filename}.md5",
	            owner  => "sonar",
        	    group  => "nogroup",
	            mode   => 0755,
		    require       => Package["sonar"],
        	}
	}
}

#!/bin/bash
tmpfile="$1"
outfile="$2"
mode="$3"
if [ -z "$tmpfile" ]; then
	echo "TMP file not specified"
	exit 1;
fi
if [ -z "$outfile" ]; then
	echo "output File not specified"
	exit 1;
fi

serial=`stat -c %Y $tmpfile`
function inject_serial()
{
	cat "$tmpfile" | sed "s/zone_serial/$serial/"

}
if [ "$mode" == "-t" ]; then
	if [ -f $outfile ]; then
		inject_serial | cmp - $outfile
		exit $?
	fi
	exit 1;
else
	inject_serial > $outfile
	exit $?
fi

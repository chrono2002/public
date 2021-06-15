#!/usr/bin/perl
 
$first = 1;
 
print "{\n";
print "\t\"data\":[\n\n";
 
for (`curl -s http://stat.vkontakte.dj/stat.getlag/?format=ini`)
{
    ($fsname, $fstype) = m/(\S+)=(\d+)/;
    $fsname =~ s!/!\\/!g;
 
    if ($fsname eq "") {
	next;
    }

    print "\t,\n" if not $first;
    $first = 0;
 
    print "\t{\n";
    print "\t\t\"{#SERVERNAME}\":\"$fsname\"\n";
    print "\t}\n";
}
 
print "\n\t]\n";
print "}\n";

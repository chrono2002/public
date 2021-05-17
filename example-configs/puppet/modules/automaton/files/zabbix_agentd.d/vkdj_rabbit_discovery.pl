#!/usr/bin/perl
 
$first = 1;
 
print "{\n";
print "\t\"data\":[\n\n";
 
for (`sudo /usr/sbin/rabbitmqctl -q list_queues -p vkdj`)
{
    ($fsname, $fstype) = m/(\S+).*(\d+)/;
    $fsname =~ s!/!\\/!g;

    if ($fsname eq "events") {
	next;
    }

    if ($fsname eq "rpc") {
	next;
    }

    if ($fsname eq "rpc_imp") {
	next;
    }

    print "\t,\n" if not $first;
    $first = 0;
 
    print "\t{\n";
    print "\t\t\"{#QUEUENAME}\":\"$fsname\"\n";
    print "\t}\n";
}
 
print "\n\t]\n";
print "}\n";

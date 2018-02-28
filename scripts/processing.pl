#!/usr/bin/perl
$|=1;

for(my $i=1; $i<=100; $i++){
    print "\r";
    my $pro="";
    for(my $j=1;$j<=$i;$j++){
	$pro .= "#";
    }
    for(my $j=1;$j<=100-$i;$j++){
        $pro .= " ";
    }    
    print "[$pro","]",$i,"%";
    sleep 1;
}
print "\n";

exit;


#!/usr/bin/perl -w
#
# Shallalist DNS RPZ 
#
# Ex de uso:
#   perl rpz.pl (no arg, creates NXDOMAIN CNAME ".")
#   perl rpz.pl A 192.168.2.1 (creates "A" redirect)
#   perl rpz.pl CNAME nowhere.local (creates "CNAME" redirect)
#   perl rpz.pl CNAME CATEGORY.local (creates category "CNAME" redirect)
 
use strict;
use warnings;
 
my ($urls);
my @categories = ('drugs','spyware','ads');
 
for my $c (0 .. (scalar(@categories) - 1)) {
        #open (my $list,'<',"blacklists/$categories[$c]/domains");
        open (my $list,'<',"BL/$categories[$c]/domains");
        chomp(my @domains = <$list>); 
        close($list);
 
        for my $d (0 .. (scalar(@domains) - 1)) {
                $urls->{lc($domains[$d])} = $categories[$c];
        }
}
 
open (my $db,'>',"./db.rpz.zone");
print $db '$TTL 1H
@       IN      SOA localhost. ns.example.com. (
                        9999999999      ; Serial  
                        1h              ; Refresh
                        15m             ; Retry
                        30d             ; Expire 
                        2h              ; Negative Cache TTL
                )
                NS  ns.example.com.
 
;; EXEMPLO ;; 
; *.example.com       CNAME .
; example.com         CNAME .
;
';
 
while (my ($key, $value) = each(%$urls) ) {
        my $redirect = 'CNAME .';
 
        if (defined($ARGV[0]) and defined($ARGV[1])) {
                $redirect = uc($ARGV[0]) . ' ' . $ARGV[1];
                if ($ARGV[1] =~ m/CATEGORY/) {
                        $redirect =~ s/CATEGORY/$value/;
                }
        }
 
        if (substr($key,0,1) ne '.') {
                print $db $key . ' IN ' . $redirect . "\n";
                print $db '*.' . $key . ' IN ' . $redirect . "\n";
        }
}
close($db);
 
exit;
 
__END__

use Test;
BEGIN { $| = 1; plan(tests => 2); chdir 't' if -d 't'; }
require 'savelogs.pl';

## test for ServerRoot with leading spaces; bug found by Chad
## Armistead @ Verio on 17 August 2011
open CONFIG, ">httpd_c.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
 ServerRoot /
 TransferLog foo.log
 ErrorLog    www/logs/error_loggy
_CONF_
close CONFIG;

system('mkdir', '-p', 'www/logs');
make_log(1024, 'foo.log');
make_log(1024, 'www/logs/error_loggy');

$savelogs = $savelogs;  ## I hate this
my $out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_c.conf 2>&1`;

ok( ! -f "foo.log" );
ok( ! -f "www/logs/error_loggy" );

#print STDERR "OUT: $out\n";

END {
    unlink "httpd_c.conf";
    unlink "foo.log";
    unlink "www/logs/error_loggy";
}

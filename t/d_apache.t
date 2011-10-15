use Test;
BEGIN { $| = 1; plan(tests => 4); chdir 't' if -d 't'; }
require 'savelogs.pl';

system('mkdir', '-p', 'www/conf');

## -- make Apache configuration files -- ##
open CONFIG, ">httpd_a.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ServerRoot /
Include    /www/conf/httpd_b.conf
_CONF_
close CONFIG;

open CONFIG, ">www/conf/httpd_b.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
TransferLog foo.log
ErrorLog    www/logs/error_loggy
_CONF_
close CONFIG;

## -- make log files -- ##
make_log(1024, 'foo.log');
system('mkdir', '-p', 'www/logs');
make_log(1024, 'www/logs/error_loggy');

ok( -f 'foo.log' );

## test apacheinclude directive
$savelogs = $savelogs;  ## silence!
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_a.conf --apacheinclude 2>&1`;

ok( $out !~ /Appending .*? to include file/ );
ok( ! -e 'foo.log' );
ok( ! -e 'www/logs/error_loggy' );

END {
    unlink "foo.log";
    unlink "www/logs/error_loggy";

    system('rm', '-r', 'www');
    unlink "httpd_a.conf";
    unlink "httpd_b.conf";
}

use Test;
BEGIN { $| = 1; plan(tests => 29); chdir 't' if -d 't'; }
require 'savelogs.pl';


## -- make Apache configuration files -- ##
open CONFIG, ">httpd_a.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ServerRoot /
Include    httpd_b.conf
_CONF_
close CONFIG;

open CONFIG, ">httpd_b.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
TransferLog foo.log
Include    httpd_c.conf
ErrorLog    www/logs/error_loggy
_CONF_
close CONFIG;

## a loopy config file
open CONFIG, ">httpd_c.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
Include     httpd_a.conf
Include     httpd_b.conf
Include     httpd_c.conf
Include     httpd_d.conf
Include     httpd_e.conf
ErrorLog    www/logs/error_cloggy
_CONF_
close CONFIG;

## globbed configuration expansion
open CONFIG, ">httpd_e.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
Include     httpd_[fgh].conf
_CONF_
close CONFIG;

## found by globbing
open CONFIG, ">httpd_f.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_floggy
_CONF_
close CONFIG;

## found by globbing
open CONFIG, ">httpd_g.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_gloggy
Include     more_httpds
_CONF_
close CONFIG;

## found by globbing; has a link back to a
open CONFIG, ">httpd_h.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
Include     link_a.conf
ErrorLog    www/logs/error_cloggy
ErrorLog    www/logs/error_hoggy
ErrorLog    /foo.log
_CONF_
close CONFIG;

## a symlink (should exclude)
symlink('httpd_a.conf', 'link_a.conf');

system('mkdir', '-p', 'more_httpds');

## found by directory expansion
open CONFIG, ">more_httpds/httpd_i.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_ioggy
_CONF_
close CONFIG;

## found by directory expansion
open CONFIG, ">more_httpds/httpd_j.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_joggy
_CONF_
close CONFIG;

## found by directory expansion
open CONFIG, ">more_httpds/httpd_k.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_koggy
Include     www/httpd_l.conf
_CONF_
close CONFIG;

system('mkdir', '-p', 'www');

## found by directory expansion
open CONFIG, ">www/httpd_l.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<_CONF_;
ErrorLog    www/logs/error_loggy
_CONF_
close CONFIG;


## -- make log files -- ##
make_log(1024, 'foo.log');
system('mkdir', '-p', 'www/logs');
make_log(1024, 'www/logs/error_loggy');  ## duplicate used in httpd_l.conf, httpd_b.conf
make_log(1024, 'www/logs/error_cloggy');
make_log(1024, 'www/logs/error_floggy');
make_log(1024, 'www/logs/error_gloggy');
make_log(1024, 'www/logs/error_hoggy');
make_log(1024, 'www/logs/error_ioggy');
make_log(1024, 'www/logs/error_joggy');
make_log(1024, 'www/logs/error_koggy');


ok( -f 'foo.log' );
ok( -f 'www/logs/error_loggy' );
ok( -f 'www/logs/error_cloggy' );
ok( -f 'www/logs/error_floggy' );
ok( -f 'www/logs/error_gloggy' );
ok( -f 'www/logs/error_hoggy' );
ok( -f 'www/logs/error_ioggy' );
ok( -f 'www/logs/error_joggy' );
ok( -f 'www/logs/error_koggy' );

## test absence of --apacheinclude directive
my $out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_a.conf 2>&1`;

ok( -f 'foo.log' );
ok( -f 'www/logs/error_loggy' );
ok( -f 'www/logs/error_cloggy' );
ok( -f 'www/logs/error_floggy' );
ok( -f 'www/logs/error_gloggy' );
ok( -f 'www/logs/error_hoggy' );
ok( -f 'www/logs/error_ioggy' );
ok( -f 'www/logs/error_joggy' );
ok( -f 'www/logs/error_koggy' );

## now test apacheinclude directive
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_a.conf --apacheinclude 2>&1`;
ok( $out =~ /Skipping 'httpd_d\.conf'/ );  ## make sure non-existent file is found and warned

## test symlinks to conf files
ok( $out =~ /Skipping 'link_a\.conf': already processed/ );

ok( ! -e 'foo.log' );
ok( ! -e 'www/logs/error_loggy' );

## test deep includes
ok( ! -e 'www/logs/error_cloggy' );

## test include wildcards
ok( ! -e 'www/logs/error_floggy' );  ## found by globbing
ok( ! -e 'www/logs/error_gloggy' );  ## found by globbing

## test log file in two include files (shared log file)
ok( ! -e 'www/logs/error_hoggy' );   ## found by globbing

## test include directories
ok( ! -e 'www/logs/error_ioggy' );   ## found by directory expansion
ok( ! -e 'www/logs/error_joggy' );   ## found by directory expansion
ok( ! -e 'www/logs/error_koggy' );   ## found by directory expansion

END {
    unlink "foo.log";
    unlink "www/logs/error_loggy";
    unlink "www/logs/error_cloggy";
    unlink "www/logs/error_floggy";
    unlink "www/logs/error_gloggy";
    unlink "www/logs/error_hoggy";
    unlink "www/logs/error_ioggy";
    unlink "www/logs/error_joggy";
    unlink "www/logs/error_koggy";

    system('rm', '-r', 'www');
    system('rm', '-r', 'more_httpds');
    unlink "httpd_a.conf";
    unlink "httpd_b.conf";
    unlink "httpd_c.conf";
    unlink "httpd_e.conf";
    unlink "httpd_f.conf";
    unlink "httpd_g.conf";
    unlink "httpd_h.conf";
    unlink "httpd_i.conf";
    unlink "httpd_j.conf";
    unlink "httpd_k.conf";
    unlink "httpd_l.conf";

    unlink "link_a.conf";
}

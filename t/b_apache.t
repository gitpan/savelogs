use Test;
BEGIN { $| = 1; plan(tests => 10); chdir 't' if -d 't'; }
require 'savelogs.pl';

## -- make Apache configuration files -- ##
open CONFIG, ">httpd_test.conf"
  or die "Could not write config file: $!\n";
print CONFIG <<'_CONF_';
ServerRoot "/"
User www
Group www
ServerAdmin webmaster@example.tld
ServerName example.tld
DocumentRoot "/usr/local/apache/htdocs"
<Directory />
    Options FollowSymLinks
    AllowOverride None
</Directory>
ErrorLog /usr/local/apache/logs/error_log
LogLevel warn
LogFormat "%h %v %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" extended
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
CustomLog /usr/local/apache/logs/access_log combined
Include   httpd_test2.conf

# default virtual hosts
<VirtualHost 123.45.67.89:80>
    SSLDisable
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteOptions inherit
    </IfModule>
</VirtualHost>

<VirtualHost 123.45.67.89:443>
    SSLEnable
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteOptions inherit
    </IfModule>
</VirtualHost>

## vaddhost: (foo.com) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           joe
    Group          joe
    ServerName     foo.com
    ServerAlias    www.foo.com bar.net www.bar.net
    ServerAdmin    joe@foo.com
    DocumentRoot   /home/joe/www/foo.com
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/joe/foo.com-access_log combined
    ErrorLog       tmp_logs/joe/foo.com-error_log
</VirtualHost>

## vaddhost: (barf.com) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           joe
    Group          joe
    ServerName     barf.com
    ServerAlias    www.barf.com
    ServerAdmin    joe@barf.com
    DocumentRoot   /home/joe/www/barf.com
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/joe/barf.com-access_log combined
    ErrorLog       tmp_logs/joe/barf.com-error_log
</VirtualHost>

## vaddhost: (savelogs.org) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           joe
    Group          joe
    ServerName     savelogs.org
    ServerAlias    www.savelogs.org
    ServerAdmin    joe@foo.com
    DocumentRoot   /home/joe/www/savelogs.org
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/joe/savelogs.org-access_log combined
    ErrorLog       tmp_logs/joe/savelogs.org-error_log
</VirtualHost>

## vaddhost: (pinemountains.com) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           joe
    Group          joe
    ServerName     pinemountains.com
    ServerAlias    www.pinemountains.com pinemountains.org www.pinemountains.org
    ServerAdmin    joe@foo.com
    DocumentRoot   /home/joe/www/pinemountains.com
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/joe/pinemountains.com-access_log combined
    ErrorLog       tmp_logs/joe/pinemountains.com-error_log
</VirtualHost>

## vaddhost: (survey.securesites.com) at 123.45.67.89:443
<VirtualHost 123.45.67.89:443>
    SSLEnable
    User           jose
    Group          jose
    ServerName     survey.securesites.com
    ServerAdmin    jose@foo.com
    DocumentRoot   /home/jose/www/survey.securesites.com
    ScriptAlias    /cgi-bin/ "/home/jose/www/cgi-bin/"
    <Directory /home/jose/www/cgi-bin>
        AllowOverride None
        Options ExecCGI
        Order allow,deny
        Allow from all
    </Directory>
    CustomLog      tmp_logs/jose/survey.securesites.com-access_log combined
    ErrorLog       tmp_logs/jose/survey.securesites.com-error_log
</VirtualHost>

## vaddhost: (ipartner.net) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           joe
    Group          joe
    ServerName     ipartner.net
    ServerAlias    www.ipartner.net
    ServerAdmin    joe@foo.com
    DocumentRoot   /home/joe/www/ipartner.net
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/joe/ipartner.net-access_log combined
    ErrorLog       tmp_logs/joe/ipartner.net-error_log
</VirtualHost>

_CONF_
close CONFIG;

open CONFIG, ">httpd_test2.conf"
  or die "Could not write config file: $!\n";
print CONFIG<<'_CONF_';
## vaddhost: (blech.net) at 123.45.67.89:80
<VirtualHost 123.45.67.89:80>
    SSLDisable
    User           jose
    Group          jose
    ServerName     blech.net
    ServerAlias    www.blech.net
    ServerAdmin    joe@blech.net
    DocumentRoot   /home/jose/www/blech.net
    Alias          /cgi-bin /dev/null
    Options        -ExecCGI
    CustomLog      tmp_logs/jose/blech.net-access_log combined
    ErrorLog       tmp_logs/jose/blech.net-error_log
</VirtualHost>
_CONF_
close CONFIG;

## -- make log files -- ##
system('mkdir', '-p', 'tmp_logs/joe');
system('mkdir', '-p', 'tmp_logs/jose');
make_log(1024, 'tmp_logs/error_log');
make_log(1024, 'tmp_logs/access_log');
make_log(1024, 'tmp_logs/joe/foo.com-access_log');
make_log(1024, 'tmp_logs/joe/foo.com-error_log');
make_log(1024, 'tmp_logs/joe/barf.com-access_log');
make_log(1024, 'tmp_logs/joe/barf.com-error_log');
make_log(1024, 'tmp_logs/joe/savelogs.org-access_log');
make_log(1024, 'tmp_logs/joe/savelogs.org-error_log');
make_log(1024, 'tmp_logs/joe/pinemountains.com-access_log');
make_log(1024, 'tmp_logs/joe/pinemountains.com-error_log');
make_log(1024, 'tmp_logs/jose/survey.securesites.com-access_log');
make_log(1024, 'tmp_logs/jose/survey.securesites.com-error_log');
make_log(1024, 'tmp_logs/jose/blech.net-access_log');
make_log(1024, 'tmp_logs/jose/blech.net-error_log');
make_log(1024, 'tmp_logs/joe/ipartner.net-access_log');
make_log(1024, 'tmp_logs/joe/ipartner.net-error_log');

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/foo.com-access_log' &&
    -f 'tmp_logs/joe/foo.com-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' &&
    -f 'tmp_logs/joe/savelogs.org-access_log' &&
    -f 'tmp_logs/joe/savelogs.org-error_log' &&
    -f 'tmp_logs/joe/pinemountains.com-access_log' &&
    -f 'tmp_logs/joe/pinemountains.com-error_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-access_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-error_log' &&
    -f 'tmp_logs/joe/ipartner.net-access_log' &&
    -f 'tmp_logs/joe/ipartner.net-error_log' &&
    -f 'tmp_logs/jose/blech.net-access_log' &&
    -f 'tmp_logs/jose/blech.net-error_log' );

##
## test non-first host
##
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="ipartner.net" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/savelogs.org-access_log' &&
    -f 'tmp_logs/joe/savelogs.org-error_log' &&
    -f 'tmp_logs/joe/pinemountains.com-access_log' &&
    -f 'tmp_logs/joe/pinemountains.com-error_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-access_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-error_log' &&
    ! -f 'tmp_logs/joe/ipartner.net-access_log' &&
    ! -f 'tmp_logs/joe/ipartner.net-error_log' &&
    -f 'tmp_logs/jose/blech.net-access_log' &&
    -f 'tmp_logs/jose/blech.net-error_log' &&
    -f 'tmp_logs/joe/foo.com-access_log' &&
    -f 'tmp_logs/joe/foo.com-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

##
## test first host
##
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="foo.com" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/savelogs.org-access_log' &&
    -f 'tmp_logs/joe/savelogs.org-error_log' &&
    -f 'tmp_logs/joe/pinemountains.com-access_log' &&
    -f 'tmp_logs/joe/pinemountains.com-error_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-access_log' &&
    -f 'tmp_logs/jose/survey.securesites.com-error_log' &&
    -f 'tmp_logs/jose/blech.net-access_log' &&
    -f 'tmp_logs/jose/blech.net-error_log' &&
    ! -f 'tmp_logs/joe/foo.com-access_log' &&
    ! -f 'tmp_logs/joe/foo.com-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

##
## test multiple hosts
##
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="savelogs.org" --apachehost="pinemountains.com" --apachehost="survey.securesites.com" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/jose/blech.net-access_log' &&
    -f 'tmp_logs/jose/blech.net-error_log' &&
    ! -f 'tmp_logs/joe/savelogs.org-access_log' &&
    ! -f 'tmp_logs/joe/savelogs.org-error_log' &&
    ! -f 'tmp_logs/joe/pinemountains.com-access_log' &&
    ! -f 'tmp_logs/joe/pinemountains.com-error_log' &&
    ! -f 'tmp_logs/jose/survey.securesites.com-access_log' &&
    ! -f 'tmp_logs/jose/survey.securesites.com-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

##
## do a host in an include file (but don't include it yet)
##
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="blech.net" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/jose/blech.net-access_log' &&
    -f 'tmp_logs/jose/blech.net-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

ok( $out =~ /specify one or more log files/ );

## now find them
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apacheinclude --apachehost="blech.net" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    ! -f 'tmp_logs/jose/blech.net-access_log' &&
    ! -f 'tmp_logs/jose/blech.net-error_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

##
## crashme tests
##
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost="." 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

## we don't do globbing (yet)
$out = `$savelogs --debug=5 --loglevel=5 --logfile=stdout --home=. --process=delete --apacheconf=httpd_test.conf --apachehost=".*" 2>&1`;

ok( -f 'tmp_logs/error_log' &&
    -f 'tmp_logs/access_log' &&
    -f 'tmp_logs/joe/barf.com-access_log' &&
    -f 'tmp_logs/joe/barf.com-error_log' );

END {
    system('rm', '-r', 'tmp_logs');
    unlink "httpd_test.conf";
    unlink "httpd_test2.conf";
}

use Test;
BEGIN { $| = 1; plan(tests => 35); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	    $result
	    $settings
	    $home
	   );

## setup bindir
$bindir = '..';
$home   = ( $< ? (getpwuid($<))[7] : '/' );
$home .= ( $home =~ m!/$! ? '' : '/' );

## version
$settings{'version'} = `egrep '^.VERSION ' $bindir/savelogs`;
chomp $settings{'version'}; $settings{'version'} =~ s/^.+'(.+?)'.*$/$1/;
chomp($result = `$bindir/savelogs --version 2>&1`);
$result =~ s/^.+ version (.+?) \(.+$/$1/;
ok( $settings{'version'}, $result );

## fetch default settings
$settings = settings(`$bindir/savelogs --settings 2>&1`);

## test default values (compatibility errors)
ok( $settings->{'apacheconf'}, 	     'undef' );
ok( $settings->{'apachelog'},  	     'TransferLog|ErrorLog|AgentLog|RefererLog|CustomLog' );
ok( $settings->{'apachelogexclude'}, '( ^/dev/null$, \| )' );
ok( $settings->{'archive'},          'undef' );
ok( $settings->{'clobber'},   	     '1' );
ok( $settings->{'compress'},  	     'undef' );
ok( $settings->{'config'},    	     'undef' );
ok( $settings->{'count'},     	     '9' );
ok( $settings->{'debug'},     	     '0' );
ok( $settings->{'dry-run'},   	     'undef' );
ok( $settings->{'ext'},       	     'undef' );
ok( $settings->{'filter'},    	     'undef' );
ok( $settings->{'force-pmh'},        'undef' );
ok( $settings->{'full-path'}, 	     'undef' );
ok( $settings->{'gtar'},      	     'undef' );
ok( $settings->{'gzip'},      	     'undef' );
ok( $settings->{'help'},      	     'undef' );
ok( $settings->{'home'},      	     $home );
ok( $settings->{'hourly'},    	     'undef' );
ok( $settings->{'log'},       	     '(  )' );
ok( $settings->{'logfile'},   	     'stdout' );
ok( $settings->{'loglevel'},  	     '0' );
ok( $settings->{'period'},    	     'undef' );
ok( $settings->{'postmovehook'},     'undef' );
ok( $settings->{'process'},          'move,compress' );
ok( $settings->{'sep'},              '.' );
ok( $settings->{'size'},             'undef' );
ok( $settings->{'stem'},             'today' );
ok( $settings->{'stemhook'},         'undef' );
ok( $settings->{'stemlink'},         'symbolic' );
ok( $settings->{'tar'},              'undef' );
ok( $settings->{'touch'},            'undef' );
ok( $settings->{'uncompress'},       'undef' );
ok( $settings->{'version'},          'undef' );
exit;


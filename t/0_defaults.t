use Test;
BEGIN { $| = 1; plan(tests => 39); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $result
	    $settings
	    $home
	    $bin
	   );

$home   = ( $< ? (getpwuid($<))[7] : '/' );
$home .= ( $home =~ m!/$! ? '' : '/' );

## version
$settings{'version'} = `egrep '^.VERSION ' $savelogs`;
chomp $settings{'version'}; $settings{'version'} =~ s/^.+'(.+?)'.*$/$1/;
chomp($result = `$savelogs --version 2>&1`);
$result =~ s/^.+ version (.+?) \(.+$/$1/;
ok( $settings{'version'}, $result );

## fetch default settings
$settings = settings(`$savelogs --settings 2>&1`);

## test default values (compatibility errors)
ok( $settings->{'apacheconf'}, 	     'undef' );
ok( $settings->{'apachelog'},  	     '(?i-xsm:^\s*(?:TransferLog|ErrorLog|AgentLog|RefererLog|CustomLog)\s+(\S+))' );
ok( $settings->{'apachelogexclude'}, '(?-xism:^/dev/null$|\|)' );
ok( $settings->{'archive'},          'undef' );
ok( $settings->{'clobber'},   	     '1' );
$bin = `which compress 2>/dev/null | grep -v 'no compress'`; chomp $bin; unless( $bin =~ /compress/ ) { $bin = '' }
ok( $settings->{'compress'},  	     $bin );
ok( $settings->{'config'},    	     'undef' );
ok( $settings->{'count'},     	     '9' );
ok( $settings->{'datefmt'},          '%y%m%d' );
ok( $settings->{'debug'},     	     '0' );
ok( $settings->{'dry-run'},   	     'undef' );
ok( $settings->{'ext'},       	     'undef' );
ok( $settings->{'filter'},    	     'undef' );
ok( $settings->{'force-pfh'},        'undef' );
ok( $settings->{'force-pmh'},        'undef' );
ok( $settings->{'full-path'}, 	     'undef' );
$bin = `which gtar 2>/dev/null | grep -v 'no gtar'`; chomp $bin; unless( $bin =~ /gtar/ ) { $bin = '' }
ok( $settings->{'gtar'},      	     $bin );
$bin = `which gzip 2>/dev/null | grep -v 'no gzip'`; chomp $bin; unless( $bin =~ /gzip/ ) { $bin = '' }
ok( $settings->{'gzip'},      	     $bin );
ok( $settings->{'help'},      	     'undef' );
ok( $settings->{'home'},      	     $home );
ok( $settings->{'hourly'},    	     'undef' );
ok( $settings->{'log'},       	     '(  )' );
ok( $settings->{'logfile'},   	     'stdout' );
ok( $settings->{'loglevel'},  	     '0' );
ok( $settings->{'nolog'},            '(  )' );
ok( $settings->{'period'},    	     'undef' );
ok( $settings->{'postfilterhook'},   'undef' );
ok( $settings->{'postmovehook'},     'undef' );
ok( $settings->{'process'},          'move,compress' );
ok( $settings->{'sep'},              '.' );
ok( $settings->{'size'},             'undef' );
ok( $settings->{'stem'},             'today' );
ok( $settings->{'stemhook'},         'undef' );
ok( $settings->{'stemlink'},         'symbolic' );
$bin = `which gtar tar 2>/dev/null | head -1 | grep -v 'no '`; chomp $bin; unless( $bin =~ /tar/ ) { $bin = '' }
ok( $settings->{'tar'},              $bin );
ok( $settings->{'touch'},            'undef' );
$bin = `which uncompress 2>/dev/null | grep -v 'no uncompress'`; chomp $bin; unless( $bin =~ /uncompress/ ) { $bin = '' }
ok( $settings->{'uncompress'},       $bin );
ok( $settings->{'version'},          'undef' );
exit;


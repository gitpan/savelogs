use Test;
BEGIN { $| = 1; plan(tests => 3); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
            $src
            $log
            $lines
	   );

## setup bindir
$bindir = '..';

$src = 'logs/access_log';
unless( -f $src ) {
    die "Could not find '$src': $!\n";
}
ok(1);

$log = 'access_log';
copy_file( $src, $log )
  or die "Could not copy '$src' to '$log': $!\n";
ok(1);

system( "$bindir/savelogs --home=. --process=filter --filter='egrep \"/default\.ida\" \$LOG' $log" );
$lines = `wc -l $log`;
chomp $lines;
$lines =~ s/^\s*(\d+).+$/$1/;
ok( $lines, 22 );
unlink $log;


exit;

use Test;
BEGIN { $| = 1; plan(tests => 11); chdir 't' if -d 't'; }
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
unlink($log);

## copy log back
copy_file( $src, $log )
  or die "Could not copy '$src' to '$log': $!\n";
ok(1);

system( "$bindir/savelogs --home=. --process=filter --filter='egrep -v \"/images/\" \$LOG | egrep -v \"(root|cmd)\\.exe\"' $log" );
$lines = `wc -l $log`;
chomp $lines;
$lines =~ s/^\s*(\d+).+$/$1/;
ok( $lines, 576 );
unlink($log);

## -- postfilterhook -- ##
$log1 = make_log(1024, 'a');
$log2 = make_log(1024, 'b');
$log3 = make_log(1024, 'c');
$return = `$bindir/savelogs --home=. --process=none --postfilterhook='tr "x" "y" < \$LOG > \$LOG.z' --log=$log1 --log=$log2 --log=$log3`;
unlink $log1;
unlink $log2;
unlink $log3;

ok( -f "$log1.z" );
$return = `grep y $log1.z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log1.z";

ok( -f "$log2.z" );
$return = `grep y $log2.z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log2.z";

ok( -f "$log3.z" );
$return = `grep y $log3.z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log3.z";

exit;

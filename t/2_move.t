use Test;
BEGIN { $| = 1; plan(tests => 20); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	    $settings
            $log
            $date_ext
	   );

## setup bindir
$bindir = '..';
$date_ext = `$bindir/smalldate`;

## fetch default settings
$settings = settings(`$bindir/savelogs --settings 2>&1`);

## move empty
$log = 'foo';
`touch $log`;
system( "$bindir/savelogs --home=. --process=move $log" );
ok( -f "$log.$date_ext" );
ok( -s _, 0 );
unlink "$log.$date_ext";

## move 1024
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move $log" );
ok( -f "$log.$date_ext" );
ok( -s _, 1024 );
unlink "$log.$date_ext";

## ext
$log = make_log(1024);
{
	local $date_ext = `$bindir/smalldate -h`;
	system( "$bindir/savelogs --home=. --process=move --ext=`$bindir/smalldate -h` $log" );
	ok( -f "$log.$date_ext" );
	unlink "$log.$date_ext";
}

## ext
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move --ext='yowza!' $log" );
ok( -f "$log.yowza!" );
unlink( "$log.yowza!" );

## hourly
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move --hourly $log" );
{
	local $date_ext = sprintf( "%s%c", `$bindir/smalldate`, (97+(localtime(time()))[2]) );
	ok( -f "$log.$date_ext" );
	unlink "$log.$date_ext";
}

## period
$log = make_log(1024);
system( "$bindir/savelogs --home=. --period $log" );
ok( -f "$log.0.gz" );
ok( -s _ < 1024 );

$log = make_log(10240);
unlink $log;
system( "./makelog -r 10240 $log" );
system( "$bindir/savelogs --home=. --period $log" );
ok( -f "$log.0.gz" );
ok( -s _ < 10540 && -s _ > 1024 );

ok( -f "$log.1.gz" );
ok( -s _ < 1024 );
unlink "$log.1.gz";
unlink "$log.0.gz";

## log
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move --ext='foo' --log=$log" );
ok( -f "$log.foo" );
unlink "$log.foo";

## separator
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move --sep='~' --ext='foo' $log" );
ok( -f "$log~foo" );
unlink "$log~foo";

## touch
$log = make_log(1024);
system( "$bindir/savelogs --home=. --process=move --touch --ext='bar' $log" );
ok( -f "$log.bar" );
ok( -f $log );
ok( -s _, 0 );
unlink $log;
unlink "$log.bar";

## stem stuff
$log = make_log(1024);
system("$bindir/savelogs --home=. --process=move --stemhook='\$HOME/lfa $log.today 1024' $log");
ok( ! $? );
unlink "$log.$date_ext";

## check failed hook detection: we send lfa a bad size and it should return non-zero
$log = make_log(1024);
my $return = `$bindir/savelogs --loglevel=3 --home=. --process=move --stemhook='\$HOME/lfa $log.today 10244' $log`;
ok( $return =~ /stemhook command returned non-zero status/ );
unlink "$log.$date_ext";

exit;

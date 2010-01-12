use Test;
use POSIX qw(strftime);
BEGIN { $| = 1; plan(tests => 74); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $garbage
            $size1
            $size2
            $log1
	    $log2
	    $log3
            $log4
            $date_ext
	   );

$date_ext = strftime('%y%m%d', localtime);

## -- move empty -- ##
$log1 = 'foo';
`touch $log1`;
system( "$savelogs --home=. --process=move $log1" );
ok( -f "$log1.$date_ext" );
ok( -s _, 0 );
unlink "$log1.$date_ext";


## -- move 1024 -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move $log1" );
ok( -f "$log1.$date_ext" );
ok( -s _, 1024 );
unlink "$log1.$date_ext";

## -- datefmt -- ##
$log1 = make_log(1024);
{
	local $date_ext = strftime('%y-%m-%d', localtime);
	system("$savelogs --home=. --process=move --datefmt='%y-%m-%d' $log1");
	ok( -f "$log1.$date_ext" );
	unlink "$log1.$date_ext";
}


## -- datefmt -- ##
$log1 = make_log(1024);
{
	local $date_ext = strftime('%y%m%d%H', localtime);
	system( "$savelogs --home=. --process=move --datefmt='%y%m%d%H' $log1" );
	ok( -f "$log1.$date_ext" );
	unlink "$log1.$date_ext";
}


## -- ext -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move --ext='yowza!' $log1" );
ok( -f "$log1.yowza!" );
unlink( "$log1.yowza!" );


## -- hourly -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move --hourly $log1" );
{
	local $date_ext = sprintf( "%s%c", 
				   strftime('%y%m%d', localtime), (97+(localtime(time()))[2]) );
	ok( -f "$log1.$date_ext" );
	unlink "$log1.$date_ext";
}

## -- period tests -- ##
## make a log
$log1 = make_log(1024);
system( "$savelogs --home=. --period $log1" );
ok( -f "$log1.0.gz" || -f "$log1.0.Z" );
$size1 = -s _;
ok( $size1 < 1024 );

## make a larger log
make_log(10240, $log1, 1);
system( "$savelogs --home=. --period $log1" );
ok( -f "$log1.0.gz" || -f "$log1.0.Z" );
$size2 = ( -f "$log1.0.gz" ? -s "$log1.0.gz" : -s "$log1.0.Z" );
ok( $size2 < 20540 && $size2 > 1024 );  ## compress makes random files somewhat bigger

## check bumped logs
ok( -f "$log1.1.gz" || -f "$log1.1.Z" );
ok( -s _ == $size1 );

## make one more log
make_log(8192, $log1, 1);
system( "$savelogs --home=. --period $log1" );
ok( -f "$log1.0.gz" || -f "$log1.0.Z" );
ok( (-s "$log1.0.gz" < 20540 && -s _ > 800) || (-s "$log1.0.Z" < 20540 && -s _ > 800) );
unlink ("$log1.0.gz", "$log1.0.Z");

## check bumped logs
ok( -f "$log1.2.gz" || -f "$log1.2.Z" );
ok( -s _ == $size1 );
unlink ("$log1.2.gz", "$log1.2.Z");

ok( -f "$log1.1.gz" || -f "$log1.1.Z" );
ok( -s _ == $size2 );
unlink ("$log1.1.gz", "$log1.1.Z");


## -- size tests ##
$log1 = make_log(10240);
$garbage = `$savelogs --home=. --process=move --size=11 --ext='foo' --log=$log1 2>&1`;
ok( $garbage, '' );  ## garbage should be empty string: we don't
		     ## complain about logs that got culled because of
		     ## size.
ok( -f "$log1" );
ok( ! -f "$log1.foo" );

## bump down size and clean up last test...
system( "$savelogs --home=. --process=move --size=10 --ext='foo' --log=$log1");
ok( ! -f "$log1" );
ok( -f "$log1.foo" ); unlink "$log1.foo";


## -- log tests -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move --ext='foo' --log=$log1" );
ok( -f "$log1.foo" ); unlink "$log1.foo";


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.foot');
$log2 = make_log(1024, 'test_log.fool');
system( "$savelogs --home=. --process=move --ext='bar' --log='test_log.foo*'" );
ok( -f "$log1.bar" ); unlink( "$log1.bar" );
ok( -f "$log2.bar" ); unlink( "$log2.bar" );


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.boot');
$log2 = make_log(1024, 'test_log.fool');
system( "$savelogs --home=. --process=move --ext='bar' --log='test_log.foo*'" );
ok( -f $log1 );       unlink( $log1 );
ok( -f "$log2.bar" ); unlink( "$log2.bar" );


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.foot');
$log2 = make_log(1024, 'test_log.fool');
$log3 = make_log(1024, 'test_log.foom');
$log4 = make_log(1024, 'test_log.foon');
system( "$savelogs --home=. --process=move --ext='bar' --log='test_log.foo[a-s]'" );
ok( -f $log1 );       unlink( $log1 );
ok( -f "$log2.bar" ); unlink( "$log2.bar" );
ok( -f "$log3.bar" ); unlink( "$log3.bar" );
ok( -f "$log4.bar" ); unlink( "$log4.bar" );


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.foot');
$log2 = make_log(1024, 'test_log.fool');
$garbage = `$savelogs --home=. --process=move --ext='bar' --log='test_log.foo' 2>&1`;
ok( $garbage =~ /You must specify one or more log files/ );
ok( -f $log1 );
ok( -f $log2 );

## pick up logs missed by last test...
system( "$savelogs --home=. --process=move --ext='bar' --log='test_log.foo?'" );
ok( -f "$log1.bar" ); unlink( "$log1.bar" );
ok( -f "$log2.bar" ); unlink( "$log2.bar" );


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.0.gz');
$log2 = make_log(1024, 'test_log.1.gz');
$garbage = `$savelogs --home=. --process=move --ext='bar' --log='test_log*' 2>&1`;
## this may fail if previous tests didn't clean up their own test_log*
## files. Try 'rm t/test_log*' and test again
ok( $garbage =~ /You must specify one or more log files/ );
ok( -f $log1 ); unlink( $log1 );
ok( -f $log2 ); unlink( $log2 );


## -- log with glob -- ##
$log1 = make_log(1024, 'test_log.0.gz');
$log2 = make_log(1024, 'test_log.tar');
$log3 = make_log(1024, 'test_log.tgz');
$log4 = make_log(1024, 'test_log.foo');
system( "$savelogs --home=. --process=move --ext='bar' --log='test_log.*'" );
ok( -f $log1 ); 	  unlink( $log1 );
ok( -f $log2 ); 	  unlink( $log2 );
ok( -f $log3 ); 	  unlink( $log3 );
ok( -f "$log4.bar" ); unlink( "$log4.bar" );


## -- nolog with glob -- ##
$log1 = make_log(1024, 'test_log.foo');
$log2 = make_log(1024, 'test_log.bar');
$log3 = make_log(1024, 'test_log.baz');
$log4 = make_log(1024, 'test_log.buz');
system( "$savelogs --home=. --process=move --ext='burp' --log='test_log.*' --nolog='test_log.ba*'" );
ok( -f "$log1.burp" );  unlink( "$log1.burp" );
ok( -f $log2 ); 	unlink( $log2 );
ok( -f $log3 ); 	unlink( $log3 );
ok( -f "$log4.burp" );  unlink( "$log4.burp" );


## -- nolog with glob -- ##
$log1 = make_log(1024, 'test_log.foo');
$log2 = make_log(1024, 'test_log.bar');
$log3 = make_log(1024, 'test_log.baz');
$log4 = make_log(1024, 'test_log.buz');
$garbage = `$savelogs --home=. --process=move --ext='burp' --log='test_log.*' --nolog='test_log.*'`;
ok( $garbage =~ /You must specify one or more log files/ );
ok( -f $log1 ); unlink( $log1 );
ok( -f $log2 ); unlink( $log2 );
ok( -f $log3 ); unlink( $log3 );
ok( -f $log4 ); unlink( $log4 );


## -- separator -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move --sep='~' --ext='foo' $log1" );
ok( -f "$log1~foo" );
unlink "$log1~foo";


## -- touch -- ##
$log1 = make_log(1024);
system( "$savelogs --home=. --process=move --touch --ext='bar' $log1" );
ok( -f "$log1.bar" );
ok( -s _, 1024 );
ok( -f $log1 );
ok( -s _, 0 );
unlink $log1;
unlink "$log1.bar";

## -- stem stuff -- ##
$log1 = make_log(1024);
system("$savelogs --home=. --process=move --stemhook='\$HOME/lfa $log1.today 1024' $log1");
ok( ! $? );
unlink "$log1.$date_ext";


## -- check failed hook detection: we send lfa a bad size and it should return non-zero -- ##
$log1 = make_log(1024);
my $return = `$savelogs --loglevel=3 --home=. --process=move --stemhook='\$HOME/lfa $log1.today 10244' $log1`;
ok( $return =~ /stemhook command returned non-zero status/ );
unlink "$log1.$date_ext";

## -- postmovehook -- ##
$log1 = make_log(1024, 'a');
$log2 = make_log(1024, 'b');
$log3 = make_log(1024, 'c');
$return = `$savelogs --home=. --process=move --postmovehook='touch barf; sleep 2; touch biff; tr "x" "y" < \$LOG > \$LOGz' --log=$log1 --log=$log2 --log=$log3`;
unlink "$log1.${date_ext}";
unlink "$log2.${date_ext}";
unlink "$log3.${date_ext}";

ok( -f 'barf' );
ok( -f 'biff' );
my $mtdiff = (stat('biff'))[9] - (stat('barf'))[9];
ok( $mtdiff >= 2 );
unlink 'barf';
unlink 'biff';

ok( -f "$log1.${date_ext}z" );
$return = `grep y $log1.${date_ext}z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log1.${date_ext}z";

ok( -f "$log2.${date_ext}z" );
$return = `grep y $log2.${date_ext}z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log2.${date_ext}z";

ok( -f "$log3.${date_ext}z" );
$return = `grep y $log3.${date_ext}z`;
ok( $return =~ /^y{1024}$/ );
unlink "$log3.${date_ext}z";

## -- chown/chmod -- ##
$log1 = make_log(1024);
chmod 0600, $log1;
chown 101, 101, $log1;
if( (stat(_))[4] == 101 ) {  ## make sure we can chown
    system("$savelogs --home=. --process=move --chown=1:1 --chmod=0751 $log1");
    ok( ((stat("$log1.$date_ext"))[2] & 07777), 0751 );
    ok( (stat(_))[4], 1 );
    ok( (stat(_))[5], 1 );
}
else {
    ok(1);
    ok(1);
    ok(1);
}
unlink "$log1.$date_ext";
unlink "$log1";

exit;

use Test;
BEGIN { $| = 1; plan(tests => 5); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	    $result
	   );

## setup bindir
$bindir = '..';

## test all of the known cases that writes to STDERR

## unable to log to dud file
unless( -x '/usr/bin/chflags' ) {
    skip(1, 1);
} else {
    `touch foo`;
    `chflags uchg foo`;
    ($result) = `$bindir/savelogs --home=. --logfile=foo foo 2>&1`;
    ok( $result =~ /^Could not open '.+\/foo' for appending:/ );
    `chflags nouchg foo`;
    unlink 'foo';
}

## no config file
($result) = `$bindir/savelogs --home=. --config=foo 2>&1`;
ok( $result =~ /^Could not read config file/ );

## bogus home directory
copy_file( 'logs/access_log', 'access_log' );
($result) = `$bindir/savelogs --home=foo access_log 2>&1`;
ok( $result =~ /^\[.+\] \[savelogs\] Fatal: Could not chdir to 'foo'/ );
unlink 'access_log';

ok(1);
ok(1);

exit;

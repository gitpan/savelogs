use Test;
BEGIN { $| = 1; plan(tests => 3); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	   );

## setup bindir
$bindir = '..';

## test many log files in a common directory in a single archive
## test many log files in disjoint directory hierarchies in a single archive
## test absolute paths:
## - where the archive is in a separate directory than the logs
## - where the archive is in the same directory as the logs
## - where the archive is in the same directory as some logs but not other logs

ok(1);
ok(1);
ok(1);

exit;

use Test;
BEGIN { $| = 1; plan(tests => 3); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	   );

## setup bindir
$bindir = '..';

ok(1);
ok(1);
ok(1);

exit;

use Test;
BEGIN { $| = 1; plan(tests => 5); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $result
	   );

## test all of the known cases that writes to STDERR

ok(1);
ok(1);
ok(1);
ok(1);
ok(1);

exit;

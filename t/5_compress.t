use Test;
BEGIN { $| = 1; plan(tests => 3); chdir 't' if -d 't'; }
require 'savelogs.pl';

ok(1);
ok(1);
ok(1);

exit;

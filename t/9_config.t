use Test;
BEGIN { $| = 1; plan(tests => 108); chdir 't' if -d 't'; }
require 'savelogs.pl';

use POSIX ();

use vars qw(
	    $bindir
            $tar
	    $log1
            $date_ext
	    $date_exty
	    $date_extc
            %contents
	   );

## setup bindir
$bindir = '..';
$tar    = `which gtar 2>/dev/null`; chomp $tar;
unless( $tar ) {
    $tar = `which tar 2>/dev/null`; chomp $tar;
}
$date_ext  = POSIX::strftime('%y%m%d', localtime);
$date_exty = POSIX::strftime('%y%m%d', localtime(time-60*60*24));
$date_extc = POSIX::strftime('%y-%m-%d', localtime);

##############################
## TEST 1a: simple log rotation
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-1a.conf" );

## check
ok( -f "var/log/messages.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );

##############################
## TEST 1b: simple log rotation with yesterday's date
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-1b.conf" );

## check
ok( -f "var/log/messages.$date_exty.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );

##############################
## TEST 1c: date string via datefmt
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-1c.conf" );

## check
ok( -f "var/log/messages.$date_extc.gz" );
ok( -s _ < 1024 && -s _ > 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );

##############################
## TEST 1d: simple archive storage
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-1d.conf" );

## check
ok( -f "var/log/messages.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

%contents = map { chomp; $_ => 8 } `$tar -ztf var/log/messages.tar.gz`;
ok( scalar(keys %contents), 1 );
ok( $contents{"messages.$date_ext"}, 8 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 1e: newsyslog-style rotation
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-1e.conf" );

## check
ok( -f "var/log/messages.0.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 2a: archiving multiple logs to multiple archives
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
system( 'mkdir', '-p', 'var/mail' );
$log1 = make_log(1024, 'var/mail/cron');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-2a.conf" );

## check
ok( -f "var/log/messages.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

ok( -f "var/log/procmail.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/procmail" );
ok( -s _, 0 );

ok( -f "var/mail/cron.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/mail/cron" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 2b: archiving multiple logs to a single archive
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
system( 'mkdir', '-p', 'var/mail' );
$log1 = make_log(1024, 'var/mail/cron');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-2b.conf" );

## check
ok( -f "var/log/logs.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );

%contents = map { chomp; $_ => 8 } `$tar -ztf var/log/logs.tar.gz`;
ok( scalar(keys %contents), 3 );
ok( $contents{"messages.$date_ext"}, 8 );
ok( $contents{"procmail.$date_ext"}, 8 );
ok( $contents{"cron.$date_ext"}, 8 );

ok( -f "var/log/messages" );
ok( -s _, 0 );

ok( -f "var/log/procmail" );
ok( -s _, 0 );

ok( -f "var/mail/cron" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 2c: archiving multiple logs to a single archive with path information
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/log/cron');
system( 'mkdir', '-p', 'var/mail' );
$log1 = make_log(1024, 'var/mail/cron');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-2c.conf" );

## check
ok( -f "var/log/logs.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );

%contents = map { chomp; $_ => 3 } `$tar -ztf var/log/logs.tar.gz`;
ok( scalar(keys %contents), 4 );
ok( $contents{"var/log/messages.$date_ext"}, 3 );
ok( $contents{"var/log/procmail.$date_ext"}, 3 );
ok( $contents{"var/log/cron.$date_ext"}, 3 );
ok( $contents{"var/mail/cron.$date_ext"}, 3 );

ok( -f "var/log/messages" );
ok( -s _, 0 );

ok( -f "var/log/procmail" );
ok( -s _, 0 );

ok( -f "var/log/cron" );
ok( -s _, 0 );

ok( -f "var/mail/cron" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 2d: archiving multiple logs to a single archive per directory
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/log/cron');
system( 'mkdir', '-p', 'var/mail' );
$log1 = make_log(1024, 'var/mail/cron');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-2d.conf" );

## check
ok( -f "var/log/logs.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/mail/logs.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );

%contents = map { chomp; $_ => 6 } `$tar -ztf var/log/logs.tar.gz`;
ok( scalar(keys %contents), 3 );
ok( $contents{"messages.$date_ext"}, 6 );
ok( $contents{"procmail.$date_ext"}, 6 );
ok( $contents{"cron.$date_ext"}, 6 );

%contents = map { chomp; $_ => 2 } `$tar -ztf var/mail/logs.tar.gz`;
ok( scalar(keys %contents), 1 );
ok( $contents{"cron.$date_ext"}, 2 );

ok( -f "var/log/messages" );
ok( -s _, 0 );

ok( -f "var/log/procmail" );
ok( -s _, 0 );

ok( -f "var/log/cron" );
ok( -s _, 0 );

ok( -f "var/mail/cron" );
ok( -s _, 0 );

## clean
ok( system( 'rm', '-r', 'var' ), 0 );


##############################
## TEST 3a: using ApacheConf
##############################

## setup directories
system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

## setup logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/error_log-domain.name1');
$log1 = make_log(1024, 'www/logs/error_log-domain.name2');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/error_log-domain.name3');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-3a.conf" );

## check
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name1.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name1.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name2.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name3.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name3.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );

## clean
ok( system( 'rm', '-r', 'usr', 'www' ), 0 );

#######################################
## TEST 3b: using ApacheConf with NoLog
## this also tests the ability of savelogs to discern same files based
## on inode (the glob for /www/logs/*_log.domain.name3 will return
## /www/ unexpanded while the Apache conf file has the full
## /usr/local/etc/httpd path).
#######################################

## setup directories
system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

## setup logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/error_log-domain.name1');
$log1 = make_log(1024, 'www/logs/error_log-domain.name2');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/error_log-domain.name3');

## run
system( "$bindir/savelogs --home=. --config=/conf/savelogs-3b.conf" );

## check
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name1.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name1.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name2.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name3" );
ok( -s _ == 1024 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name3" );
ok( -s _ == 1024 );

## clean
ok( system( 'rm', '-r', 'usr', 'www' ), 0 );

exit;

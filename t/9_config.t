use Test;
BEGIN { $| = 1; plan(tests => 138); chdir 't' if -d 't'; }
require 'savelogs.pl';

use POSIX ();

use vars qw(
            $tar
	    $log1
            $date_ext
	    $date_exty
	    $date_extc
            %contents
	   );

## setup
$tar    = `which gtar 2>/dev/null | grep -v 'no '`; chomp $tar;
unless( $tar ) {
    $tar = `which tar 2>/dev/null | grep -v 'no '`; chomp $tar;
}
unless( $tar ) {
    die "No tar or gtar found.\n";
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
system( "$savelogs --home=. --config=/conf/savelogs-1a.conf" );

## check
ok( -f "var/log/messages.$date_ext.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
system( 'rm', '-r', 'var' );

##############################
## TEST 1b: simple log rotation with yesterday's date
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$savelogs --home=. --config=/conf/savelogs-1b.conf" );

## check
ok( -f "var/log/messages.$date_exty.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
system( 'rm', '-r', 'var' );

##############################
## TEST 1c: date string via datefmt
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$savelogs --home=. --config=/conf/savelogs-1c.conf" );

## check
ok( -f "var/log/messages.$date_extc.gz" );
ok( -s _ < 1024 && -s _ > 0 );

## clean
system( 'rm', '-r', 'var' );

##############################
## TEST 1d: simple archive storage
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$savelogs --home=. --config=/conf/savelogs-1d.conf" );

## check
ok( -f "var/log/messages.tar.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

%contents = map { chomp; $_ => 8 } `$tar -ztf var/log/messages.tar.gz`;
ok( scalar(keys %contents), 1 );
ok( $contents{"messages.$date_ext"}, 8 );

## clean
system( 'rm', '-r', 'var' );


##############################
## TEST 1e: newsyslog-style rotation
##############################

## setup
system( 'mkdir', '-p', 'var/log' );
$log1 = make_log(1024, 'var/log/messages');

## run
system( "$savelogs --home=. --config=/conf/savelogs-1e.conf" );

## check
ok( -f "var/log/messages.0.gz" );
ok( -s _ < 1024 && -s _ > 0 );
ok( -f "var/log/messages" );
ok( -s _, 0 );

## clean
system( 'rm', '-r', 'var' );


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
system( "$savelogs --home=. --config=/conf/savelogs-2a.conf" );

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
system( 'rm', '-r', 'var' );


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
system( "$savelogs --home=. --config=/conf/savelogs-2b.conf" );

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
system( 'rm', '-r', 'var' );


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
system( "$savelogs --home=. --config=/conf/savelogs-2c.conf" );

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
system( 'rm', '-r', 'var' );


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
system( "$savelogs --home=. --config=/conf/savelogs-2d.conf" );

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
system( 'rm', '-r', 'var' );


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
system( "$savelogs --home=. --config=/conf/savelogs-3a.conf" );

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
system( 'rm', '-r', 'usr', 'www' );

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
system( "$savelogs --home=. --config=/conf/savelogs-3b.conf" );

## check
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name1.$date_ext.gz"
    and -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name1.$date_ext.gz" 
    and -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name2.$date_ext.gz" 
    and -s _ < 1024 && -s _ > 0 );
ok( -f "usr/local/etc/httpd/logs/access_log-domain.name3" 
    and -s _ == 1024 );
ok( -f "usr/local/etc/httpd/logs/error_log-domain.name3" 
    and -s _ == 1024 );

## clean
system( 'rm', '-r', 'usr', 'www' );


#######################################
## TEST 4a: ApacheConf with multiple ApacheHost directives
#######################################

## setup directories
system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

## setup logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');

## run
system( "$savelogs --home=. --config=/conf/savelogs-4a.conf" );

## check
ok( ! -f "usr/local/etc/httpd/logs/access_log-domain.name1"
    and -f "usr/local/etc/httpd/logs/access_log-domain.name1.0.gz"
    and -s _ < 1024 && -s _ > 0 );
ok( ! -f "usr/local/etc/httpd/logs/access_log-domain.name3"
    and -f "usr/local/etc/httpd/logs/access_log-domain.name3.0.gz"
    and -s _ < 1024 && -s _ > 0 );

my @log_sigs = ();
my $have_md5 = eval "require Digest::MD5";

if( $have_md5 ) {
    for my $n (1, 3) {
        open SIG, "<usr/local/etc/httpd/logs/access_log-domain.name${n}.0.gz";
        my $sig = Digest::MD5->new;
        $sig->addfile(*SIG);
        close SIG;
        push @log_sigs, $sig->digest;
    }
}

## make more logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');

system( "$savelogs --home=. --config=/conf/savelogs-4a.conf" );

if( $have_md5 ) {
    my @sig_check = ();

    for my $n (1, 3) {
        open SIG, "<usr/local/etc/httpd/logs/access_log-domain.name${n}.1.gz";
        my $sig = Digest::MD5->new;
        $sig->addfile(*SIG);
        close SIG;
        push @sig_check, $sig->digest;
    }

    ok( $log_sigs[0] eq $sig_check[0] and
        $log_sigs[1] eq $sig_check[1] );
}
else {
    ok("test skipped: no md5");
}

## clean
system( 'rm', '-r', 'usr', 'www' );


#######################################
## TEST 5a: ApacheConf with Log blocks
#######################################

## setup directories
system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

## setup logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
$log1 = make_log(1024, 'www/logs/access_log-domain.name7');

## run
system( "$savelogs --home=. --config=/conf/savelogs-5a.conf" );

my $log_path = 'usr/local/etc/httpd/logs/';
ok( ! -f "${log_path}access_log-domain.name1"
    and -f "${log_path}access_log-domain.name1.0.gz"
    and -s _ < 1024 && -s _ > 0 );

ok( ! -f "${log_path}access_log-domain.name3"
    and -f "${log_path}access_log-domain.name3.0.gz"
    and -s _ < 1024 && -s _ > 0 );

ok(   -f "${log_path}access_log-domain.name5"           ## touch should create this
    and ! -s _                                          ## zero length
    and -f "${log_path}access_log-domain.name5.0.gz"
    and -s _ < 1024 && -s _ > 0 );

ok( ! -f "${log_path}access_log-domain.name7" 
    and -f "${log_path}access_log-domain.name7.0.gz"
    and -s _ < 1024 && -s _ > 0 );

$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
$log1 = make_log(1024, 'www/logs/access_log-domain.name7');
system( "$savelogs --home=. --config=/conf/savelogs-5a.conf" );    # .1


$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
$log1 = make_log(1024, 'www/logs/access_log-domain.name7');
system( "$savelogs --home=. --config=/conf/savelogs-5a.conf" );    # .2 for name1, name3, etc.


$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
$log1 = make_log(1024, 'www/logs/access_log-domain.name7');
system( "$savelogs --home=. --config=/conf/savelogs-5a.conf" );    # .3 for name5, name7

ok( ! -f "${log_path}access_log-domain.name1.3.gz" );
ok( ! -f "${log_path}access_log-domain.name3.3.gz" );
ok(   -f "${log_path}access_log-domain.name5.3.gz" );
ok(   -f "${log_path}access_log-domain.name7.3.gz" );


$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
$log1 = make_log(1024, 'www/logs/access_log-domain.name7');
system( "$savelogs --home=. --config=/conf/savelogs-5a.conf" );    # .4 for name7

ok( ! -f "${log_path}access_log-domain.name1.4.gz" );
ok( ! -f "${log_path}access_log-domain.name3.4.gz" );
ok( ! -f "${log_path}access_log-domain.name5.4.gz" );
ok(   -f "${log_path}access_log-domain.name7.4.gz" );

## clean
system( 'rm', '-r', 'usr', 'www' );

#######################################
## TEST 5b: ApacheConf with Log blocks
#######################################

system( 'mkdir', '-p', 'var/log' );
system( 'mkdir', '-p', 'var/mail' );
$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

ok(   -f "var/log/messages" and ! -s _ );                           ## default is touch
ok(   -f "var/log/messages.0.gz" and -s _ < 1024 && -s _ > 0 );     ## period'd
ok( ! -f "var/log/procmail" );                                      ## no touch for this <Log> section
ok(   -f "var/log/procmail.0.gz" and -s _ < 1024 && -s _ > 0 );     ## period'd
ok( ! -f "var/mail/cron" and ! -s _ and
    ! -f "var/mail/fish" and ! -s _ );
ok(   -f "var/mail/cron.0.gz" and -s _ < 1024 && -s _ > 0 and
      -f "var/mail/fish.0.gz" and -s _ < 1024 && -s _ > 0 );
ok(   -f "var/mail/horses" and ! -s _ );
ok(   -f "var/mail/horses.0.gz" and -s _ < 1024 && -s _ > 0 );
ok( ! -f "var/mail/doggy" );
ok(   -f "var/mail/doggy.0.gz" and -s _ < 1024 && -s _ > 0 );
ok( ! -f "var/mail/doggerel" );
ok(   -f "var/mail/doggerel.0.gz" and -s _ < 1024 && -s _ > 0 );
ok( ! -f "var/mail/dogmeat" );
ok(   -f "var/mail/dogmeat.0.gz" and -s _ < 1024 && -s _ > 0 );


$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

$log1 = make_log(1024, 'var/log/messages');
$log1 = make_log(1024, 'var/log/procmail');
$log1 = make_log(1024, 'var/mail/cron');
$log1 = make_log(1024, 'var/mail/fish');
$log1 = make_log(1024, 'var/mail/horses');
$log1 = make_log(1024, 'var/mail/doggy');
$log1 = make_log(1024, 'var/mail/doggerel');
$log1 = make_log(1024, 'var/mail/dogmeat');
system( "$savelogs --home=. --config=/conf/savelogs-5b.conf" );   # .1 for messages, procmail, cron

ok( -f "var/log/messages.2.gz"  and ! -f "var/log/messages.3.gz" );   ## block setting
ok( -f "var/log/procmail.3.gz"  and ! -f "var/log/messages.4.gz" );   ## block setting
ok( -f "var/mail/cron.1.gz"     and ! -f "var/mail/cron.2.gz" );      ## inherited
ok( -f "var/mail/fish.1.gz"     and ! -f "var/mail/fish.2.gz" );      ## inherited
ok( -f "var/mail/horses.0.gz"   and ! -f "var/mail/horses.1.gz" );    ## block setting (none)
ok( -f "var/mail/doggy.4.gz"    and ! -f "var/mail/doggy.5.gz" );     ## globbed
ok( -f "var/mail/doggerel.4.gz" and ! -f "var/mail/doggerel.5.gz" );  ## globbed
ok( -f "var/mail/dogmeat.4.gz"  and ! -f "var/mail/dogmeat.5.gz" );   ## globbed

## clean
system( 'rm', '-r', 'var' );


#######################################
## TEST 5c: ApacheConf with Log blocks
#######################################

## setup directories
system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

## setup logs
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');

## run
system( "$savelogs --home=. --config=/conf/savelogs-5c.conf" );

$log_path = 'usr/local/etc/httpd/logs/';
ok(   -f "${log_path}access_log-domain.name1"
    and ! -s _                                          ## zero length
    and -f "${log_path}access_log-domain.name1.0.gz"
    and -s _ < 1024 && -s _ > 0 );

## no period for name3
my @files = glob("${log_path}access_log-domain.name3.[0-9][0-9][0-9][0-9]*.gz");
ok( scalar(@files) == 1);
ok(   -f "${log_path}access_log-domain.name3"
    and ! -s _                                          ## zero length
    and ! -f "${log_path}access_log-domain.name3.0.gz"
    and   -f $files[0]
    and -s _ < 1024 && -s _ > 0 );

ok( ! -f "${log_path}access_log-domain.name5"
    and -f "${log_path}access_log-domain.name5.0.gz"
    and -s _ < 1024 && -s _ > 0 );

sleep 1;
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
system( "$savelogs --home=. --config=/conf/savelogs-5c.conf" );    # .1
@files = glob("${log_path}access_log-domain.name3.*.gz");
ok( scalar(@files) == 2 );

sleep 1;
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
system( "$savelogs --home=. --config=/conf/savelogs-5c.conf" );    # .2 for name1, name3, etc.
@files = glob("${log_path}access_log-domain.name3.*.gz");
ok( scalar(@files) == 3 );

sleep 1;
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
system( "$savelogs --home=. --config=/conf/savelogs-5c.conf" );    # .3 for name5, name7
@files = glob("${log_path}access_log-domain.name3.*.gz");
ok( scalar(@files) == 4 );

sleep 1;
$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');
system( "$savelogs --home=. --config=/conf/savelogs-5c.conf" );    # .4 for name7
@files = glob("${log_path}access_log-domain.name3.*.gz");
ok( scalar(@files) == 5 );

system( 'rm', '-r', 'usr', 'www' );


#######################################
## TEST 5d: ApacheConf with no block
#######################################

system( 'mkdir', '-p', 'usr/local/etc/httpd/logs' );
system( 'mkdir', '-p', 'usr/local/etc/httpd/conf' );
symlink( 'usr/local/etc/httpd', 'www' );
system( 'cp', '-p', 'conf/httpd.conf', 'www/conf' );

$log1 = make_log(1024, 'www/logs/access_log-domain.name1');
$log1 = make_log(1024, 'www/logs/access_log-domain.name3');
$log1 = make_log(1024, 'www/logs/access_log-domain.name5');

system( "$savelogs --home=. --config=/conf/savelogs-5d.conf" );  ## shouldn't do anything

@files = glob("${log_path}access_log-domain.name1.[0-9]*.gz");
ok( scalar(@files) == 0 );

system( 'rm', '-r', 'usr', 'www' );

exit;

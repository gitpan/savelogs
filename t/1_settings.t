use Test;
BEGIN { $| = 1; plan(tests => 70); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $bindir
	    $settings
	    $settings_new
	   );

## setup bindir
$bindir = '..';

## fetch default settings
$settings = settings(`$bindir/savelogs --settings 2>&1`);

## binaries
for my $bin (qw( gzip compress uncompress )) {
    my $binpath = `which $bin 2>/dev/null | head -1 | grep -v 'no $bin'`;
    my $arg = '';
    if( $binpath ) {
	chomp $binpath;
	$arg = "--$bin=$binpath";
    }
    else {
	$binpath = '';
    }
    $settings_new = settings(`$bindir/savelogs $arg --settings`);
    ok( $settings_new->{$bin}, $binpath );
}

## tar and gtar are special because gtar is always preferred
for my $bin ( qw(gtar tar) ) {
    my $binpath = `which gtar tar 2>/dev/null | head -1 | grep -v 'no '`;
    my $arg = '';
    if( $binpath ) {
	chomp $binpath;
	$arg = "--$bin=$binpath";
    }
    else {
	$binpath = '';
    }

    $settings_new = settings(`$bindir/savelogs $arg --settings`);
    ok( $settings_new->{$bin}, $binpath );
}

## apacheconf
$settings_new = settings(`$bindir/savelogs --apacheconf=/www/foo/httpd.conf --settings 2>&1`);
ok( $settings_new->{'apacheconf'}, 'www/foo/httpd.conf' );

## apachelog
$settings_new = settings(`$bindir/savelogs --apachelog=TransferLog --settings 2>&1`);
ok( $settings_new->{'apachelog'}, 'TransferLog' );

## apachelogexclude
$settings_new = settings(`$bindir/savelogs --apachelogexclude= --settings 2>&1`);
ok( $settings_new->{'apachelogexclude'}, '(  )' );

## clobber
$settings_new = settings(`$bindir/savelogs --clobber --settings 2>&1`);
ok( $settings_new->{'clobber'}, '1' );
$settings_new = settings(`$bindir/savelogs --noclobber --settings 2>&1`);
ok( $settings_new->{'clobber'}, '0' );

## config
$settings_new = settings(`$bindir/savelogs --config=/etc/foo.conf --settings 2>&1`);
ok( $settings_new->{'config'}, 'etc/foo.conf' );

## count
$settings_new = settings(`$bindir/savelogs --count=100 --settings 2>&1`);
ok( $settings_new->{'count'}, '99' );

## dry-run
$settings_new = settings(`$bindir/savelogs --dry-run --settings 2>&1`);
ok( $settings_new->{'dry-run'}, '1' );

## datefmt
$settings_new = settings(`$bindir/savelogs --datefmt='%y-%m-%d' --settings 2>&1`);
ok( $settings_new->{'datefmt'}, '%y-%m-%d' );

## ext
$settings_new = settings(`$bindir/savelogs --ext=foo --settings 2>&1`);
ok( $settings_new->{'ext'}, 'foo' );

## filter
$settings_new = settings(`$bindir/savelogs --filter='egrep -v "localhost" \$LOG' --settings 2>&1`);
ok( $settings_new->{'filter'}, 'egrep -v "localhost" $LOG' );

## force-pfh
$settings_new = settings(`$bindir/savelogs --force-pfh -settings 2>&1`);
ok( $settings_new->{'force-pfh'}, '1' );

## force-pmh
$settings_new = settings(`$bindir/savelogs --force-pmh -settings 2>&1`);
ok( $settings_new->{'force-pmh'}, '1' );

## full-path
$settings_new = settings(`$bindir/savelogs --full-path --settings 2>&1`);
ok( $settings_new->{'full-path'}, '1' );

## gripe
$settings_new = settings(`$bindir/savelogs --nogripe --settings 2>&1`);
ok( $settings_new->{'gripe'}, '0' );

## hourly
$settings_new = settings(`$bindir/savelogs --hourly --settings 2>&1`);
ok( $settings_new->{'hourly'}, '1' );

## log
$settings_new = settings(`$bindir/savelogs --log=/var/log/messages --settings 2>&1`);
ok( $settings_new->{'log'}, '( /var/log/messages )' );

## loglevel
$settings_new = settings(`$bindir/savelogs --loglevel=5 --settings 2>&1`);
ok( $settings_new->{'loglevel'}, '5' );

## nolog
$settings_new = settings(`$bindir/savelogs --nolog=/var/log/messages --settings 2>&1`);
ok( $settings_new->{'nolog'}, '( /var/log/messages )' );

## period
$settings_new = settings(`$bindir/savelogs --period --process=all --settings 2>&1`);
ok( $settings_new->{'period'}, '0' );
ok( $settings_new->{'process'}, 'move,compress' );

## period
$settings_new = settings(`$bindir/savelogs --period=14 --settings 2>&1`);
ok( $settings_new->{'period'}, '14' );
ok( $settings_new->{'count'}, '13' );

## period + filter
$settings_new = settings(`$bindir/savelogs --period=8 --process=filter --settings 2>&1`);
ok( $settings_new->{'count'}, '7' );
ok( $settings_new->{'process'}, 'move,filter,compress' );

## period + filter
$settings_new = settings(`$bindir/savelogs --period --process=move --settings 2>&1`);
ok( $settings_new->{'count'}, '9' );
ok( $settings_new->{'process'}, 'move,compress' );

## period + filter
$settings_new = settings(`$bindir/savelogs --period --process=none --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,compress' );

## postfilterehook
$settings_new = settings(`$bindir/savelogs --postfilterhook='/bin/killall httpd' --settings 2>&1`);
ok( $settings_new->{'postfilterhook'}, '/bin/killall httpd' );

## postmovehook
$settings_new = settings(`$bindir/savelogs --postmovehook='/bin/killall httpd' --settings 2>&1`);
ok( $settings_new->{'postmovehook'}, '/bin/killall httpd' );

## process
$settings_new = settings(`$bindir/savelogs --process='all' --settings 2>&1`);
ok( $settings_new->{'process'}, 'all' );

## process
$settings_new = settings(`$bindir/savelogs --process='filter' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter' );

## process
$settings_new = settings(`$bindir/savelogs --process='none' --settings 2>&1`);
ok( $settings_new->{'process'}, 'none' );

## process
$settings_new = settings(`$bindir/savelogs --process='archive,compress' --settings 2>&1`);
ok( $settings_new->{'process'}, 'archive,compress' );

## process
$settings_new = settings(`$bindir/savelogs --process='filter' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter' );

## process
$settings_new = settings(`$bindir/savelogs --period --process='filter' --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,compress' );

## process
$settings_new = settings(`$bindir/savelogs --filter='egrep foo \$LOG' --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,compress' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='all' --settings 2>&1`);
ok( $settings_new->{'process'}, 'all' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='none' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='all' --settings 2>&1`);
ok( $settings_new->{'process'}, 'all' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='filter' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='move' --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='compress' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter,compress' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='move,filter' --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='archive,compress' --settings 2>&1`);
ok( $settings_new->{'process'}, 'filter,archive,compress' );

## process + filter
$settings_new = settings(`$bindir/savelogs --filter='foo' --process='move,archive,compress,delete' --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive,compress,delete' );

## process + archive
$settings_new = settings(`$bindir/savelogs --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,archive,compress' );

## process + archive
$settings_new = settings(`$bindir/savelogs --archive=bob.tar --filter=foo --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive,compress' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=none --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'archive' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=move --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,archive' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=all --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'all' );

## process + archive
$settings_new = settings(`$bindir/savelogs --period --filter=foo --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive,compress' );

## process + archive
$settings_new = settings(`$bindir/savelogs --period --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,archive,compress' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=archive --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'archive' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=move,filter --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=move,delete --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,archive,delete' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=move,filter,archive,compress --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive,compress' );

## process + archive
$settings_new = settings(`$bindir/savelogs --process=move,archive,compress --filter=foo --archive=bob.tar --settings 2>&1`);
ok( $settings_new->{'process'}, 'move,filter,archive,compress' );

## sep
$settings_new = settings(`$bindir/savelogs --sep='~' --settings 2>&1`);
ok( $settings_new->{'sep'}, '~' );

## size
$settings_new = settings(`$bindir/savelogs --size=12 --settings 2>&1`);
ok( $settings_new->{'size'}, '12288' );

## stem
$settings_new = settings(`$bindir/savelogs --stem=foo --settings 2>&1`);
ok( $settings_new->{'stem'}, 'foo' );

## stemhook
$settings_new = settings(`$bindir/savelogs --stemhook='ls -l ~/var/log; sleep 3' --settings 2>&1`);
ok( $settings_new->{'stemhook'}, 'ls -l ~/var/log; sleep 3' );

## stemlink
$settings_new = settings(`$bindir/savelogs --stemlink=hard --settings 2>&1`);
ok( $settings_new->{'stemlink'}, 'hard' );

## stemlink
$settings_new = settings(`$bindir/savelogs --stemlink=copy --settings 2>&1`);
ok( $settings_new->{'stemlink'}, 'copy' );

## touch
$settings_new = settings(`$bindir/savelogs --touch --settings 2>&1`);
ok( $settings_new->{'touch'}, '1' );

exit;

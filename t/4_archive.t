use Test;
BEGIN { $| = 1; plan(tests => 53); chdir 't' if -d 't'; }
require 'savelogs.pl';

use vars qw(
	    $tar
            @dirs
	    $log1
            %contents
	   );

$tar    = `which gtar 2>/dev/null`; chomp $tar;
unless( $tar ) {
    $tar = `which tar 2>/dev/null`; chomp $tar;
}

## test many log files in a common directory in a single archive
for my $i ( 1..5 ) {
    $log1 = make_log( 1024, "test_log.$i" );
    system( "$savelogs --home=. --process=archive --archive='test_log.tar' $log1" );
    unlink( $log1 );
}
ok( -f 'test_log.tar' );
ok( -s _ > 5120 );

## check the contents
%contents = map { chomp; $_ => 8 } `$tar -tf test_log.tar`;
ok( scalar(keys %contents), 5 );
for my $i ( 1..5 ) {
    ok( $contents{"test_log.$i"}, 8 );
}
ok( unlink( 'test_log.tar' ) );


## test many logs in disjoint directory hierarchies with unique names
@dirs = qw( foo bar baz );
system( 'mkdir', '-p', @dirs );
for my $dir ( @dirs ) {
    for my $i ( 1..5 ) {
	$log1 = make_log( 1024, "$dir/test_log.$dir.$i" );
	system( "$savelogs --home=. --process=archive --archive='./test_log.tar' $log1" );
	unlink( $log1 );
    }
    ok( system( 'rm', '-r', $dir ), 0 );
}
ok( -f 'test_log.tar' );
ok( -s _ > 15360 );

## check the contents
%contents = map { chomp; $_ => 4 } `$tar -tf test_log.tar`;
ok( scalar(keys %contents), (scalar(@dirs)*5) );
for my $dir ( @dirs ) {
    for my $i ( 1..5 ) {
	ok( $contents{"test_log.$dir.$i"}, 4 );
    }
}
ok( unlink( 'test_log.tar' ) );


## test many logs in disjoint directory hierarchies with common names
@dirs = qw( foo bar baz );
system( 'mkdir', '-p', @dirs );
for my $dir ( @dirs ) {
    for my $i ( 1..5 ) {
	$log1 = make_log( 1024, "$dir/test_log.$i" );
	system( "$savelogs --home=. --process=archive --archive='./test_log.tar' --full-path $log1" );
	unlink( $log1 );
    }
    ok( system( 'rm', '-r', $dir ), 0 );
}
ok( -f 'test_log.tar' );
ok( -s _ > 15360 );

## check the contents
%contents = map { chomp; $_ => 2 } `$tar -tf test_log.tar`;
ok( scalar(keys %contents), (scalar(@dirs)*5) );
for my $dir ( @dirs ) {
    for my $i ( 1..5 ) {
	ok( $contents{"$dir/test_log.$i"}, 2 );
    }
}
ok( unlink( 'test_log.tar' ) );


exit;

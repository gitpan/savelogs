sub settings {
    my @settings = @_;
    my %settings;

    for ( @settings ) {
	my($key,$value) = $_ =~ m/^\s*SET: (\S+)\s*=>\s+(.*)$/;
	next unless $key;
	$settings{$key} = $value;
    }
    return \%settings;
}

## make a log file for testing
sub make_log {
    my $size = shift || 1;
    my $file = shift || 'test_log';

    open FILE, ">$file"
      or die "Could not open $file: $!\n";

    print FILE 'x' x $size;
    close FILE;

    return $file;
}

sub copy_file {
    my $src = shift;
    my $dst = shift;
    my $buf;
    my $size = 1024;

    unless( -f $src ) {
	warn "Could not find '$src': $!\n";
	return undef;
    }

    open SRC, $src
      or do {
	  warn "Could not open '$src' for copy: $!\n";
	  return undef;
      };

    open DST, ">$dst"
      or do {
	  warn "Could not open '$dst' for write: $!\n";
	  close SRC;
	  return undef;
      };

    ## copy loop (stolen from File::Copy)
    for (;;) {
        my ($r, $w, $t);
        defined($r = sysread(SRC, $buf, $size))
            or do {
		warn "Error in sysread: $!\n";
		close SRC; close DST;
		return undef;
	    };
        last unless $r;
        for ($w = 0; $w < $r; $w += $t) {
            $t = syswrite(DST, $buf, $r - $w, $w)
                or do {
		    warn "Error in syswrite: $!\n";
		    close SRC; close DST;
		    return undef;
		};
        }
    }

    close DST;
    close SRC;
}

1;

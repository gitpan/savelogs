use ExtUtils::MakeMaker;

## add configuration files for packing here
my @conf_files = qw( savelogs.conf.sample );

## add program files for packing here
my @exe_files  = qw( savelogs );

## add pod files for packing here. They live in 'pods/'
my %man_files = (
		 'pods/rotation.pod'  => 'rotation',
		 'savelogs'           => 'savelogs',
		);

## where configuration files live in the source tree
my $confdir    = 'conf';

WriteMakefile(
    'NAME'	   => 'savelogs',
    'VERSION_FROM' => 'savelogs',
    'AUTHOR'       => 'Scott Wiersdorf <scott@perlcode.org>',
    'PL_FILES'     => { map {("$confdir/$_.PL" => "$confdir/$_")} @conf_files },
    'EXE_FILES'    => [ @exe_files ],
    'MAN1PODS'     => { 
		       map { ($_ => '$(INST_MAN1DIR)/'.$man_files{$_}.'.$(MAN1EXT)') }
		       keys %man_files 
		      },
    'realclean'    => { FILES => join(' ', map { "$confdir/$_" } @conf_files), },
);

sub MY::post_constants {
    return qq!
VTMPDIR        = _tmp.\$(DISTNAME)
CONF           = $confdir
INST_CONFDIR   = blib/etc
INSTALLCONFDIR = /etc
!;
}

sub MY::clean {
    my $self = shift;
    local $_ = $self->MM::clean();
    s/\t/\trm -rf \$(VTMPDIR)\n\t/;
    return $_;
}

sub MY::postamble {
    my @m;

    ## call $(INST_CONFDIR)/.exists
    push @m, "config :: \$(INST_CONFDIR)/.exists\n";
    push @m, "\t\@\$(NOOP)\n\n";

    ## make .exists file
    push @m, "\$(INST_CONFDIR)/.exists :: \$(PERL_INC)/perl.h\n";
    push @m, "\t\@\$(MKPATH) \$(INST_CONFDIR)\n";
    push @m, "\t\@\$(EQUALIZE_TIMESTAMP) \$(PERL_INC)/perl.h \$(INST_CONFIDIR)/.exists\n\n";
    push @m, "\t-\@\$(CHMOD) \$(PERM_RWX) \$(INST_CONFDIR)\n\n";

    ## blib section
    my $confdir = join(' ', map { "\$(INST_CONFDIR)/$_" } @conf_files);
    push @m, "all :: $confdir\n";
    push @m, "\t\@\$(NOOP)\n\n";

    ## put @conf_files in their blib/etc home
    for my $conf ( @conf_files ) {
	push @m, "\$(INST_CONFDIR)/$conf: \$(CONF)/$conf.PL Makefile \$(INST_CONFDIR)/.exists\n";
	push @m, "\t\@rm -f \$(INST_CONFDIR)/$conf\n";
	push @m, "\tcp \$(CONF)/$conf \$(INST_CONFDIR)/$conf\n";
	push @m, "\t\$(FIXIN) \$(INST_CONFDIR)/$conf\n";
	push @m, "\t-\@\$(CHMOD) \$(PERM_RW) \$(INST_CONFDIR)/$conf\n\n";
    }

    ## vdist section
    push @m, "vdist :: all vtardist\n";
    push @m, "\t\@\$(NOOP)\n\n";

    ## vtardist section
    push @m, "vtardist : \$(DISTVNAME).tar\$(SUFFIX)-vinstall\n\n";

    ## vinstall tarball section
    push @m, "\$(DISTVNAME).tar\$(SUFFIX)-vinstall : vdistdir\n";
    push @m, "\tcd \$(VTMPDIR); \$(TAR) \$(TARFLAGS) ../\$(DISTVNAME).tar *\n";
    push @m, "\t\$(RM_RF) \$(VTMPDIR)\n";
    push @m, "\t\$(COMPRESS) \$(DISTVNAME).tar\n\n";

    ## vdistdir section
    push @m, "vdistdir :\n";
    push @m, "\t" . '@$(RM_RF) $(VTMPDIR)' . "\n";
    push @m, "\t" . '@$(MKPATH) $(VTMPDIR)' . "\n";
    push @m, "\t" . '@$(MOD_INSTALL) \\' . "\n";
    push @m, "\t\t" . '$(INST_BIN) ../../$(VTMPDIR)$(INSTALLBIN) \\' . "\n";
    push @m, "\t\t" . '$(INST_SCRIPT) ../../$(VTMPDIR)$(INSTALLSCRIPT) \\' . "\n";
    push @m, "\t\t" . '$(INST_MAN1DIR) ../../$(VTMPDIR)$(INSTALLMAN1DIR) \\' . "\n";
    push @m, "\t\t" . '$(INST_MAN3DIR) ../../$(VTMPDIR)$(INSTALLMAN3DIR) \\' . "\n";
    push @m, "\t\t" . '$(INST_CONFDIR) ../../$(VTMPDIR)/$(INSTALLCONFDIR)' . "\n\n";

    return join('', @m);
}

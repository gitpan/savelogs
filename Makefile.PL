require 5.005;

## borrowed from the Mail::SpamAssassin package:
#
# set PREFIX (default = /usr)
# set SYSCONFDIR (default = /etc)
# set INST_PREFIX (default = [same as PREFIX])
# set INST_SYSCONFDIR (default = [same as SYSCONFDIR])
#
# For example, to install in your home dir:
#
#   perl Makefile.PL PREFIX=/home/jm/sausr SYSCONFDIR=/home/jm/saetc
#
# Or to build a package in /tmp/build, but with its internal paths
# referring to /usr and /etc:
#
#   perl Makefile.PL PREFIX=/tmp/build/usr SYSCONFDIR=/tmp/build/etc \
#                       INST_PREFIX=/usr INST_SYSCONFDIR=/etc
##

use ExtUtils::MakeMaker;
use Config;  ## FIXME: is this used?

$ExtUtils::MakeMaker::Recognized_Att_Keys{'SYSCONFDIR'} = 1;
$ExtUtils::MakeMaker::Recognized_Att_Keys{'INST_SYSCONFDIR'} = 1;
$ExtUtils::MakeMaker::Recognized_Att_Keys{'INST_PREFIX'} = 1;

## add configuration files for packing here
my @conf_files = qw( savelogs.conf.lint savelogs.conf.sample );
my $conf_files = join(' ', @conf_files);

## add pod files for packing here. They live in 'pods/'
my %man1files = (
		 'pods/rotation.pod'  => '$(INST_MAN1DIR)/rotation.$(MAN1EXT)',
		 'savelogs'           => '$(INST_MAN1DIR)/savelogs.$(MAN1EXT)',
		);

WriteMakefile(
    'NAME'	   => 'savelogs',

    'VERSION_FROM' => 'savelogs',

    'EXE_FILES'    => [ 'savelogs' ],

    'MAN1PODS'     => { %man1files },

    'PL_FILES'     => { },

    'AUTHOR'       => 'Scott Wiersdorf <scott@perlcode.org>',

    'ABSTRACT'     => 'complete log file rotation program w/ documentation',
);

sub MY::install {
    package MY;
    my $self = shift;
    my $inherited = $self->SUPER::install (@_);

    ## add inst_cfs
    $inherited =~ s/^(install :: .*)$/$1 inst_conf/gm;
    $inherited;
}

sub MY::postamble {
    package MY;
    my $self = shift;

    my $sysconfdir = $self->{SYSCONFDIR};
    $sysconfdir ||= '/usr/local/etc';

    my $instsysconfdir = $self->{INST_SYSCONFDIR};
    $instsysconfdir ||= $sysconfdir;

    my $instprefix = $self->{INST_PREFIX};
    $instprefix ||= $self->{PREFIX};

    qq!

CONF_FILES      = $conf_files
SYSCONFDIR      = $sysconfdir
INST_SYSCONFDIR = $instsysconfdir
INST_PREFIX     = $instprefix

! .

q!

LOCAL_CONF_DIR           = $(INST_SYSCONFDIR)
PKG_CONF_DIR             = $(SYSCONFDIR)

inst_conf: $(PKG_CONF_DIR) $(LOCAL_CONF_DIR)
	for file in $(CONF_FILES) ; do \
	  $(RM_F) $(PKG_CONF_DIR)/$$file; \
	  $(CP) conf/$$file $(PKG_CONF_DIR)/$$file; \
	  $(CHMOD) $(PERM_RW) $(PKG_CONF_DIR)/$$file; \
	done

$(PKG_CONF_DIR):
	$(MKPATH) $@

$(LOCAL_CONF_DIR):
	$(MKPATH) $@

!;

}

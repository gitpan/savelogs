use ExtUtils::MakeMaker;
my @scripts = ( savelogs );
my %man1pods = ( 'pods/rotation.pod'  => '$(INST_MAN1DIR)/rotation.$(MAN1EXT)',
		 'script/savelogs'    => '$(INST_MAN1DIR)/savelogs.$(MAN1EXT)', );
WriteMakefile(
    'NAME'              => 'savelogs',
    'VERSION_FROM'      => 'script/savelogs',
    'PREREQ_PM'         => { },
    'EXE_FILES'         => [ map { "script/$_" } @scripts ],
    'MAN1PODS'          => { %man1pods },
    ($] >= 5.005
     ? (ABSTRACT_FROM    => 'script/savelogs',
	AUTHOR           => 'Scott Wiersdorf <scott@perlcode.org>') 
     : ()),
);

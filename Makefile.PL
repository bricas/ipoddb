use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'iPodDB',
	VERSION_FROM => 'lib/iPodDB.pm',
	EXE_FILES    => [ qw( bin/ipoddb ) ],
	PREREQ_PM    => {
		Wx              => 0,
		Mac::iPod::DB   => 0,
		Class::Accessor => 0,
		Path::Class     => 0,
		File::Copy      => 0,
		Test::More      => 0
	}
);

sub MY::postamble {
	return <<'MAKE_EXE';
exe:
	pp -I $(INST_LIB) -I $(INST_ARCHLIB) -M utf8 -g -o ipoddb.exe bin\ipoddb

MAKE_EXE
}
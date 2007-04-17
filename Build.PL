use strict;

use Module::Build;

my $build = Module::Build->new(
    module_name        => 'iPodDB',
    dist_author        => 'Brian Cassidy <bricas@cpan.org>',
    license            => 'perl',
    create_readme      => 1,
    create_makefile_pl => 'traditional',
    script_files       => [ qw( bin/ipoddb ) ],
    requires           => {
        'Wx'              => 0,
        'Mac::iPod::DB'   => 0,
        'Class::Accessor' => 0,
        'Path::Class'     => 0,
        'File::Copy'      => 0,
    },
    build_requres      => {
        'Test::More' => 0,
    }
);

# This was in the old Makefile.PL

#sub MY::postamble {
#    return <<'MAKE_EXE';
#exe:
#    pp -I $(INST_LIB) -I $(INST_ARCHLIB) -M utf8 -g -o ipoddb.exe bin\ipoddb
#
#MAKE_EXE
#}

$build->create_build_script;

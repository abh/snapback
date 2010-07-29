use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME                => 'snapback',
   AUTHOR              => 'Ask Bjoern Hansen <ask@develooper.com>',
   VERSION_FROM        => 'lib/Snapback.pm',
   ABSTRACT            => "Snapshot backup",
   PL_FILES            => { },
   EXE_FILES           => [ 'snapback' ],
   #    PM => {
   #        'GeoDNS.pm' => '$(INST_LIBDIR)/App/HWD.pm',
   #    },
   PREREQ_PM => 
   {
    'Twiggy'     => 0,
    'Tatsumaki'  => 0,
    'JSON' => 2.12,
    'File::Slurp' => 0,
    'KiokuDB' => 0.40,
    'KiokuDB::Backend::BDB' => 0,
    'KiokuDB::Backend::Files' => 0,
   },
   MAN3PODS            => { }, # no need for docs on these
   dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
   clean               => { FILES => 'cover_db pm_to_blib' },
);

sub MY::postamble {
    return <<'MAKE_FRAG';

.PHONY: testcover

cover:
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover make test
	cover

MAKE_FRAG
}

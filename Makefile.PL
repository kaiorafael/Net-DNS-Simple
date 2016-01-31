use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Net::DNS::Simple',
    AUTHOR           => q{Kaio Rafael (kaiux) <perl@kaiux.com>},
    VERSION_FROM     => 'lib/Net/DNS/Simple.pm',
    ABSTRACT_FROM    => 'lib/Net/DNS/Simple.pm',
    LICENSE          => 'gpl_3',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Net::DNS'              => 0.83,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Net-DNS-Simple-*' },
);

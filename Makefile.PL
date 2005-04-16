use ExtUtils::MakeMaker;

require 5.006001;

do "mkheader" or die $@ || "mkheader: $!";

WriteMakefile(
    'NAME'		=> 'Lingua::JA::MacJapanese',
    'VERSION_FROM'	=> 'MacJapanese.pm',
    'ABSTRACT_FROM'	=> 'MacJapanese.pm',
    'AUTHOR'		=> 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>',
    'clean'		=> { FILES=> 'fmmacja.h tomacja.h' },
);


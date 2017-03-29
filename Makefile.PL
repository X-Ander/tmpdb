use 5.010;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
	( NAME              => 'DBIx::TmpDB'
	, VERSION_FROM      => 'lib/DBIx/TmpDB.pm' # finds $VERSION
	, PREREQ_PM         => { DBI => 1.612 } # e.g., Module::Name => 1.1
	, LICENSE           => 'perl'
	, ABSTRACT_FROM     => 'lib/DBIx/TmpDB.pm' # retrieve abstract from module
	, AUTHOR            => 'Alexander Lebedev <x-ander@alexplus.ru>'
	, EXE_FILES         => [ 'bin/tmpdb' ]
	);

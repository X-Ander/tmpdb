package DBIx::TmpDB::Util;

use strict;
use warnings;

use 5.010;

use Exporter 'import';

our @EXPORT_OK = qw/find_program/;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

my @paths =
	( split(qr/:/, $ENV{PATH} // '')
	, '/usr/local/sbin'
	, '/usr/local/bin'
	, '/usr/sbin'
	, '/usr/bin'
	, '/sbin'
	, '/bin'
	);

sub find_program { my ($prog) = @_;
	for (@paths) {
		my $full_path = "$_/$prog";
		return $full_path if -f $full_path && -x $full_path;
	}
	return undef;
}

1;
__END__

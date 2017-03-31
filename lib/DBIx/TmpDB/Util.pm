package DBIx::TmpDB::Util;

use strict;
use warnings;

use 5.010;

use File::Spec::Functions;
use Exporter 'import';

our @EXPORT_OK = qw/find_program/;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

my @paths =
	( path
	, catfile(rootdir, qw/usr local sbin/)
	, catfile(rootdir, qw/usr local bin/)
	, catfile(rootdir, qw/usr       sbin/)
	, catfile(rootdir, qw/usr       bin/)
	, catfile(rootdir, qw/          sbin/)
	, catfile(rootdir, qw/          bin/)
	);

sub find_program { my ($prog) = @_;
	for (@paths) {
		my $full_path = catfile $_, $prog;
		return $full_path if -f $full_path && -x $full_path;
	}
	return undef;
}

1;
__END__

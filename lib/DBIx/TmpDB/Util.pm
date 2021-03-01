package DBIx::TmpDB::Util;

use strict;
use warnings;

use 5.010;

use File::Spec::Functions;
use Exporter 'import';

our @EXPORT_OK = qw/find_program cmp_vs max_v/;
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

sub cmp_vs { my ($a, $b) = @_;
	my $i = 0;
	while ($i < @$a && $i < @$b) {
		my $ai = $a->[$i]; my $bi = $b->[$i];
		return  1 if $ai > $bi;
		return -1 if $ai < $bi;
		$i++;
	}
	@$a <=> @$b
}

sub max_v {
	my @max_v = ();
	for my $v (@_) {
		my @cur_v = split qr/\./, $v;
		@max_v = @cur_v if cmp_vs(\@cur_v, \@max_v) > 0;
	}
	@max_v ? join('.', @max_v) : ''
}

1;
__END__

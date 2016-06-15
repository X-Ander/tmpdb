package DBIx::TmpDB;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw/tmpdb_backends tmpdb_new/;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

sub _find_pms { my ($dir) = @_;
	opendir my $dh, $dir or return ();
	my @pms = map {
		-f "$dir/$_" && m/^([^.].*)\.pm$/ ? ($1) : ()
	} readdir $dh;
	closedir $dh;
	return @pms;
}

sub _can_run { my ($backend) = @_;
	my $pkg = __PACKAGE__ . "::$backend";
	eval "require $pkg";
	return $@ ? 0 : eval $pkg . "::can_run";
}

sub tmpdb_backends {
	my $pkg_dir = __PACKAGE__;
	$pkg_dir =~ s{::}{/}g;

	my %pm_hash = map {
		$_ => 1
	} map {
		_find_pms $_
	} map {
		my $d = "$_/$pkg_dir";
		-d $d ? ($d) : ()
	} @INC;

	return grep {
		_can_run $_;
	} keys %pm_hash;
}

sub tmpdb_new { my ($backend) = @_;
	my $pkg = __PACKAGE__ . "::$backend";
	eval "require $pkg";
	return $@ ? undef : eval $pkg . "->new";
}

1;
__END__

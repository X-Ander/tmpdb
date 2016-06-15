package DBIx::TmpDB;

use strict;
use warnings;

use 5.010;

use Exporter 'import';

our @EXPORT_OK = qw/tmpdb_backends tmpdb_new/;
our %EXPORT_TAGS = (all => \@EXPORT_OK);

our $VERSION = '0.01';

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

=head1 NAME

DBIx::TmpDB - Temporary database runner

=head1 SYNOPSIS

  use DBI;
  use DBIx::TmpDB qw/tmpdb_backends tmpdb_new/;

  for my $backend (tmpdb_backends)
  {
      my $db = tmpdb_new $backend;
      my $dbh = DBI->connect($db->dsn, $db->username, $db->password);
      ...
      $dbh->disconnect;
      ...
      if (my @prog = $db->client_program)
      {
          system @prog;
      }
      else
      {
          print "The $backend backend provides no client program\n";
      }
  }

=head1 DESCRIPTION

This module creates and destroys temporary databases. It runs, if nessesary,
temporary instanses of the database servers.

Only MySQL is supported now. You are welcome to add more backends.

=over

=item @backends = tmpdb_backends

Returns a list of available backend names.

=item $db = tmpdb_new <backend>

Creates the database by the backend name, and returns its object reference.
The database will be destroyed when the object goes out of scope.

=back

=head1 AUTHOR

Alexander Lebedev E<lt>x-ander@alexplus.ruE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Alexandra Plus Ltd.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

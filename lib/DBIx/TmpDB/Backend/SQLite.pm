package DBIx::TmpDB::Backend::SQLite;

use strict;
use warnings;

use 5.010;

use Carp;
use File::Temp qw/tempdir/;
use File::Spec::Functions;
use DBI;

use DBIx::TmpDB::Util qw/find_program/;

sub can_run {
	eval "require DBD::SQLite";
	return !$@;
}

sub client_program { my ($self) = @_;
	my $prog = $self->{prog};
	return $prog ?
		( $prog
		, $self->database
		) : ();
}

sub new { my ($class, $persist) = @_;
	my $self = bless {}, $class;

	my @cleanup = $persist ? () : (CLEANUP => 1);

	$self->{prog} = find_program('sqlite3');
	$self->{workdir} = tempdir('sqlite_test_XXXX', TMPDIR => 1, @cleanup);
	$self->{database} = catfile $self->{workdir}, "db.sqlite";

	return $self;
}

sub cleanup { }

sub database { my ($self) = @_; return $self->{database}; }

sub dsn { my ($self) = @_;
	return 'DBI:SQLite:dbname=' . $self->database;
}

sub username { '' }
sub password { '' }

1;
__END__

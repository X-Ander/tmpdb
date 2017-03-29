package DBIx::TmpDB::Backend::SQLite;

use strict;
use warnings;

use 5.010;

use Carp;
use File::Temp qw/tempdir/;
use DBI;

use DBIx::TmpDB::Util qw/find_program/;

sub can_run {
	return defined find_program('sqlite3');
}

sub client_program { my ($self) = @_;
	my $prog = $self->{prog};
	return $prog ?
		( $prog
		, $self->database
		) : ();
}

sub new { my ($class) = @_;
	my $self = bless {}, $class;

	$self->{prog} = find_program('sqlite3')
		or croak "Can't find SQLite executable";

	$self->{workdir} = tempdir('sqlite_test_XXXX', TMPDIR => 1, CLEANUP => 1);
	$self->{database} = $self->{workdir} . "/db.sqlite";

	return $self;
}

sub database { my ($self) = @_; return $self->{database}; }

sub dsn { my ($self) = @_;
	return 'DBI:SQLite:dbname=' . $self->database;
}

sub username { '' }
sub password { '' }

1;
__END__

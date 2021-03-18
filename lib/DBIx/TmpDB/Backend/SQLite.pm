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

sub new { my ($class, $persist, $workdir) = @_;
	my $self = bless {}, $class;

	my @cleanup = $persist ? () : (CLEANUP => 1);

	$self->{persist} = $persist;
	$self->{prog} = find_program('sqlite3');
	if ($workdir) {
		$self->{workdir} = $workdir;
		$self->{tempdir} = 0;
	} else {
		$self->{workdir} = tempdir('sqlite_test_XXXX', TMPDIR => 1, @cleanup);
		$self->{tempdir} = 1;
	}
	$self->{database} = catfile $self->{workdir}, "db.sqlite";

	return $self;
}

sub cleanup { my ($self) = @_;
	unlink $self->{database} unless $self->{tempdir} || $self->{persist};
}

sub database { my ($self) = @_; return $self->{database}; }

sub dsn { my ($self) = @_;
	return 'DBI:SQLite:dbname=' . $self->database;
}

sub username { '' }
sub password { '' }

1;
__END__

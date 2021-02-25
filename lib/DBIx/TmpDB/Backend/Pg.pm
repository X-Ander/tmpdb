package DBIx::TmpDB::Backend::Pg;

use strict;
use warnings;

use 5.010;

use Carp;
use File::Spec::Functions;
use File::Temp qw/tempdir/;
use DBI;

use DBIx::TmpDB::Util qw/find_program/;

my $binDir = '/usr/lib/postgresql/11/bin';
my $initdbCmd = "$binDir/initdb";
my $pgCmd = "$binDir/postgres";

sub can_run {
	for my $prog ($initdbCmd, $pgCmd) {
		return 0 unless -x $prog;
	}
	return 1;
}

sub client_program { my ($self) = @_;
	my $prog = find_program('psql');
	return $prog ?
		( $prog
		, '-h', $self->{socketdir}
		, $self->database
		, $self->username
		, '-w'
		) : ();
}

sub new { my ($class, $persist) = @_;
	my $self = bless {}, $class;

	for my $prog ($initdbCmd, $pgCmd) {
		-x $prog or croak "Can't find '$prog' executable";
	}

	my @cleanup = $persist ? () : (CLEANUP => 1);
	#my @cleanup = ();

	$self->{persist} = $persist;
	$self->{workdir} = tempdir('pg_test_XXXX', TMPDIR => 1, @cleanup);
	$self->{datadir}    = catfile $self->{workdir}, 'data';
	$self->{socketdir}  = catfile $self->{workdir}, 'sock';
	$self->{pidfile}    = catfile $self->{workdir}, 'pid';

	for my $dir ($self->{datadir}, $self->{socketdir}) {
		mkdir $dir, 0700 or croak "Can't create directory '$dir': $!";
	}

	my $initCmd = "$initdbCmd -D $self->{datadir} 2>&1";
	my $initOut = `$initCmd`;

	croak "'$initCmd' failed: $initOut" if $?;

	my $pid = fork;
	croak "fork failed: $!" unless defined $pid;

	unless ($pid) { # child process
		my $log = catfile $self->{workdir}, 'postgres.log';
		open my $fh, '>', $log or croak "Can't create log file '$log': $!";
		open STDOUT, '>&', $fh or croak "Can't dup STDOUT: $!";
		open STDERR, '>&', $fh or croak "Can't dup STDERR: $!";

		exec $pgCmd,
			'-D', $self->{datadir},
			'-h', '',
			'-k', $self->{socketdir},
			'-c', 'external_pid_file=' . $self->{pidfile},
			or croak "Can't launch postgres";
	}

	my $sleep_cnt = 10;
	while ($sleep_cnt && ! -f $self->{pidfile}) {
		sleep 1;
		$sleep_cnt--;
	}
	croak "Looks like postgres has not started" unless -f $self->{pidfile};

	$self->{pid} = $pid;

	my $dbh = DBI->connect($self->dsn('postgres'), $self->username, $self->password,
		{AutoCommit => 1, RaiseError => 1, PrintError => 0});
	$dbh->do("CREATE DATABASE ". $self->database);
	$dbh->disconnect;

	return $self;
}

sub cleanup { my ($self) = @_;
	if ($self->{pid}) {
		kill 'TERM', $self->{pid};

		my $sleep_cnt = 10;
		while ($sleep_cnt && -f $self->{pidfile}) {
			sleep 1;
			$sleep_cnt--;
		}
		croak "Looks like postgres does not respond" if -f $self->{pidfile};
	}
}

sub DESTROY { my ($self) = @_;
	unless ($self->{persist}) {
		$self->cleanup;
	}
}

sub database { 'test' }

sub dsn { my ($self, $dbname) = @_;
	$dbname //= $self->database;
	return "DBI:Pg:dbname=$dbname;host=" . $self->{socketdir};
}

sub username { $ENV{USER} }
sub password { '' }

1;
__END__

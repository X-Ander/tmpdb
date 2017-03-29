package DBIx::TmpDB::Backend::MySQL;

use strict;
use warnings;

use 5.010;

use Carp;
use File::Temp qw/tempdir/;
use DBI;

use DBIx::TmpDB::Util qw/find_program/;

sub can_run {
	for my $prog (qw/mysqld mysql_install_db/) {
		return 0 unless find_program($prog);
	}
	return 1;
}

sub client_program { my ($self) = @_;
	my $prog = find_program('mysql');
	return $prog ?
		( $prog
		, '--no-defaults'
		, '--socket='   . $self->socket
		, '--user='     . $self->username
		, '--password=' . $self->password
		,                 $self->database
		) : ();
}

sub new { my ($class) = @_;
	my $self = bless {}, $class;

	for my $prog (qw/mysqld mysql_install_db/) {
		$self->{$prog} = find_program($prog)
			or croak "Can't find '$prog' executable";
	}

	my $defaults = `$self->{mysqld} --print-defaults`;

	for my $opt (qw/basedir lc-messages-dir/) {
		if ($defaults =~ m/--$opt=(\S+)/) {
			$self->{$opt} = $1;
		}
	}

	$self->{workdir} = tempdir('mysql_test_XXXX', TMPDIR => 1, CLEANUP => 1);
	$self->{datadir}    = $self->{workdir} . '/data';
	$self->{tmpdir}     = $self->{workdir} . '/tmp';
	$self->{'pid-file'} = $self->{workdir} . '/pid';
	$self->{socket}     = $self->{workdir} . '/sock';

	for my $dir ($self->{datadir}, $self->{tmpdir}) {
		mkdir $dir, 0700 or croak "Can't create directory '$dir': $!";
	}

	my $install_opts = '--no-defaults';

	for my $opt (qw/basedir datadir/) {
		if (exists $self->{$opt}) {
			$install_opts .= " --$opt=" . $self->{$opt};
		}
	}

	my $install_cmd = "$self->{mysql_install_db} $install_opts 2>&1";
	my $install_output = `$install_cmd`;

	croak "'$install_cmd' failed: $install_output" if $?;

	my $pid = fork;
	croak "fork failed: $!" unless defined $pid;

	unless ($pid) { # child process
		my $log = $self->{workdir} . '/mysqld.log';
		open my $fh, '>', $log or croak "Can't create log file '$log': $!";
		open STDOUT, '>&', $fh or croak "Can't dup STDOUT: $!";
		open STDERR, '>&', $fh or croak "Can't dup STDERR: $!";

		exec $self->{mysqld}, '--no-defaults', '--skip-networking',
			map {
				exists $self->{$_} ? ("--$_=" . $self->{$_}) : ()
			} qw/basedir lc-messages-dir datadir tmpdir pid-file socket/

			or croak "Can't launch mysqld";
	}

	my $sleep_cnt = 10;
	while ($sleep_cnt && ! -f $self->{'pid-file'}) {
		sleep 1;
		$sleep_cnt--;
	}
	croak "Looks like mysqld has not started" unless -f $self->{'pid-file'};

	$self->{pid} = $pid;

	my $dbh = DBI->connect($self->dsn_base, $self->username, $self->password,
		{AutoCommit => 1, RaiseError => 1, PrintError => 0});
	$dbh->do("CREATE DATABASE ". $self->database ." CHARACTER SET utf8");
	$dbh->disconnect;

	return $self;
}

sub DESTROY { my ($self) = @_;
	if ($self->{pid}) {
		kill 'TERM', $self->{pid};

		my $sleep_cnt = 10;
		while ($sleep_cnt && -f $self->{'pid-file'}) {
			sleep 1;
			$sleep_cnt--;
		}
		croak "Looks like mysqld does not respond" if -f $self->{'pid-file'};
	}
}

sub socket { my ($self) = @_;
	return $self->{socket};
}

sub database { 'test' }

sub dsn_base { my ($self) = @_;
	return 'DBI:mysql:mysql_socket=' . $self->socket;
}

sub dsn { my ($self) = @_;
	return $self->dsn_base . ':database=' . $self->database;
}

sub username { 'root' }
sub password { '' }

1;
__END__

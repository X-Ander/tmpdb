use strict;
use warnings;

use DBI;

use Test::More tests => 12;

BEGIN { use_ok 'DBIx::TmpDB', ':all'; }

SKIP: {
	skip "Pg backend can't run", 11
		unless grep {$_ eq 'Pg'} tmpdb_backends;

	pass "Pg backend can run";

	my $db = tmpdb_new 'Pg';
	ok $db, "Pg backend is ready";

	can_ok $db, qw/dsn username password/;

	like $db->dsn, qr{^DBI:Pg:}, "Good DSN";

	is $db->username, $ENV{USER}, "Good username";
	is $db->password, '', "Good password";

	my $dbh = DBI->connect($db->dsn, $db->username, $db->password);

	ok $dbh, "Connected";

	ok defined($dbh->do(
		'CREATE TABLE test (foo INTEGER NOT NULL, bar VARCHAR(20) NOT NULL)'
	));

	is $dbh->do("INSERT INTO test (foo, bar) VALUES (42, 'do not panic')"), 1;

	if ($dbh) {
		$dbh->disconnect;
	}

	my @cp = $db->client_program;

	skip "Pg client executable is not found", 2 unless @cp;

	ok scalar(@cp) > 1, "Client program has arguments";
	like $cp[0], qr/\bpg\b/, "Good client program executable";
}

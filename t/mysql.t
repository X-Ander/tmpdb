use strict;
use warnings;

use DBI;

use Test::More tests => 10;

BEGIN { use_ok 'DBIx::TmpDB', ':all'; }

SKIP: {
	skip "MySQL backend can't run", 9
		unless grep {$_ eq 'MySQL'} tmpdb_backends;

	pass "MySQL backend can run";

	my $db = tmpdb_new 'MySQL';
	ok $db, "MySQL backend is ready";

	can_ok $db, qw/dsn username password/;

	like $db->dsn, qr{^DBI:mysql:mysql_socket=[^:]+:database=test$}, "Good DSN";

	is $db->username, 'root', "Good username";
	is $db->password, '',     "Good password";

	my $dbh = DBI->connect($db->dsn, $db->username, $db->password);

	ok $dbh, "Connected";

	if ($dbh) {
		$dbh->disconnect;
	}

	my @cp = $db->client_program;

	skip "MySQL client executable is not found", 2 unless @cp;

	ok scalar(@cp) > 1, "Client program has arguments";
	like $cp[0], qr/\bmysql\b/, "Good client program executable";
}

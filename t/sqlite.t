use strict;
use warnings;

use DBI;

use Test::More tests => 10;

BEGIN { use_ok 'DBIx::TmpDB::Backend::SQLite'; }

ok DBIx::TmpDB::Backend::SQLite::can_run, "Can run";

my $db = new_ok 'DBIx::TmpDB::Backend::SQLite';

can_ok $db, qw/dsn username password/;

like $db->dsn, qr{^DBI:SQLite:dbname=/.*$}, "Good DSN";

is $db->username, '', "Good username";
is $db->password, '', "Good password";

my $dbh = DBI->connect($db->dsn, $db->username, $db->password);

ok $dbh, "Connected";

if ($dbh) {
	$dbh->disconnect;
}

my @cp = $db->client_program;

ok scalar(@cp) > 1, "Client program has arguments";
like $cp[0], qr/\bsqlite3$/, "Good client program executable";

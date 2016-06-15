use strict;
use warnings;

use DBI;

use Test::More tests => 8;

BEGIN { use_ok 'DBIx::TmpDB::MySQL'; }

ok DBIx::TmpDB::MySQL::can_run, "Can run";

my $mysql = new_ok 'DBIx::TmpDB::MySQL';

can_ok $mysql, qw/dsn username password/;

like $mysql->dsn, qr{^DBI:mysql:mysql_socket=/[^:]+:database=test$}, "Good DSN";

is $mysql->username, 'root', "Good username";
is $mysql->password, '',     "Good password";

my $dbh = DBI->connect($mysql->dsn, $mysql->username, $mysql->password);

ok $dbh, "Connected";

if ($dbh) {
	$dbh->disconnect;
}

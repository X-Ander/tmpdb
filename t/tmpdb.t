use strict;
use warnings;

use DBI;

use Test::More tests => 4;

BEGIN { use_ok 'DBIx::TmpDB', ':all'; }

my @backends = tmpdb_backends;

is scalar(@backends), 2, "There is two backends";

my $db = tmpdb_new($backends[0]);
ok $db, "First backend loaded";

$db = tmpdb_new($backends[1]);
ok $db, "Second backend loaded";

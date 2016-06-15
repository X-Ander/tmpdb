use strict;
use warnings;

use DBI;

use Test::More tests => 3;

BEGIN { use_ok 'DBIx::TmpDB', ':all'; }

my @backends = tmpdb_backends;

ok @backends, "There are backends";

my $db = tmpdb_new($backends[0]);

ok $db, "First backend loaded";

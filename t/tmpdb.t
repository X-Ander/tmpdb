use strict;
use warnings;

use DBI;

use Test::More tests => 2;

BEGIN { use_ok 'DBIx::TmpDB', ':all'; }

my @backends = tmpdb_backends;
my $cnt = @backends;

ok $cnt > 0, "There are some backends ($cnt)";

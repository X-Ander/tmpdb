use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok 'DBIx::TmpDB::Util', ':all'; }

is find_program('ls'), '/bin/ls', "Found the 'ls' program"

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok 'DBIx::TmpDB::Util', ':all'; }

my $prog = 'perl';

if ($^O =~ m/win/i) {
	$prog = 'perl.exe';
}

my $path = find_program($prog);

like $path, qr/\b$prog\b/, "Found the '$prog' program: $path";

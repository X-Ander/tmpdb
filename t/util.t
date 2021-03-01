use strict;
use warnings;

use Test::More tests => 4;

BEGIN { use_ok 'DBIx::TmpDB::Util', ':all'; }

my $prog = 'perl';

if ($^O =~ m/win/i) {
	$prog = 'perl.exe';
}

my $path = find_program($prog);

like $path, qr/\b$prog\b/, "Found the '$prog' program: $path";

subtest 'cmp_vs' => sub {
	plan tests => 8;

	is cmp_vs([], []), 0, "Empty lists is equal";
	is cmp_vs(['0'], []), 1, "Simpest list is greater than the empty list";
	is cmp_vs(['0'], ['1']), -1, "0 < 1";
	is cmp_vs(['0', '1'], ['1']), -1, "0.1 < 1";
	is cmp_vs(['01'], ['1']), 0, "01 = 1";
	is cmp_vs(['10'], ['1']), 1, "10 > 1";
	is cmp_vs(['2', '1'], ['1']), 1, "2.1 > 1";
	is cmp_vs([qw/1 9 9 9/], [qw/2 0 0/]), -1, "1.9.9.9 < 2.0.0";
};

subtest 'max_v' => sub {
	plan tests => 2;

	is max_v(), '', 'No maximum';
	is max_v(qw/1.3 9 5.6 0.11 8.8/), '9', 'Maximum found';
};

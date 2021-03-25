use Module::Build;
my $build = Module::Build->new (
	module_name => 'DBIx::TmpDB',
	license  => 'perl',
	requires => {
		'perl' => '5.20.2',
		'DBI'  => '1.612',
	},
);
$build->create_build_script;

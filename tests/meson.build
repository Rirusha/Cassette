cassette_test_sources = [
  vapi_sources,
  cassette_client_sources,
  resources
]

test('Test Jsoner',
  executable('jsoner_test',
    sources: ['jsoner_test.vala'] + cassette_test_sources,
    dependencies: cassette_dependencies,
    include_directories: config_h_dir,
    c_args: cassette_c_args,
  )
)

test('Test Client Utils',
  executable('client_utils_test',
    sources: ['client_utils_test.vala'] + cassette_test_sources,
    dependencies: cassette_dependencies,
    include_directories: config_h_dir,
    c_args: cassette_c_args,
  )
)

test('Test Info Database',
  executable('info_db_test',
    sources: ['info_db_test.vala'] + cassette_test_sources,
    dependencies: cassette_dependencies,
    include_directories: config_h_dir,
    c_args: cassette_c_args,
  )
)

test('Test Storager',
  executable('storager_test',
    sources: ['storager_test.vala'] + cassette_test_sources,
    dependencies: cassette_dependencies,
    include_directories: config_h_dir,
    c_args: cassette_c_args,
  )
)


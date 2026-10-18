test('info-db',
  executable('test-info-db',
    sources: files('test-info-db.vala'),
    dependencies: lib_dep,
  )
)

test('storager',
  executable('test-storager',
    sources: files('test-storager.vala'),
    dependencies: lib_dep,
  )
)

test('content-heap',
  executable('test-content-heap',
    sources: [
      files('test-content-heap.vala'),
      files(meson.project_source_root() / 'libtape' / 'src' / 'heap' / 'content-heap.vala'),
    ],
    dependencies: gio_dep,
  )
)

if get_option('token') != ''
  test_api_conf = configuration_data()
  test_api_conf.set_quoted('TOKEN', get_option('token'))

  configure_file(output: 'test-config.h', configuration: test_api_conf)

  test('api',
    executable('test-api',
      sources: files(
        'test-api.vala',
        'test-config.vapi',
      ),
      dependencies: lib_dep,
      c_args: [ '-include', 'test-config.h' ],
      include_directories: include_directories('.'),
    )
  )
endif

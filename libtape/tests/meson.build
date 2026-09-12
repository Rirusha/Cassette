if get_option('token') != ''
  conf = configuration_data()
  conf.set_quoted('TOKEN', get_option('token'))

  configure_file(output: 'test-config.h', configuration: conf)
  config_h_dir = include_directories('.')

  test('API Test',
    executable(
      'api-test',
      sources: [ 'api-test.vala' ] + sources + [ 'test-config.vapi' ],
      dependencies: dependencies,
      c_args: [ '-include', 'test-config.h' ],
      include_directories: config_h_dir,
    )
  )
endif

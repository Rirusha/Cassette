vapi_sources = files(
  'config.vapi',
)

vala_sources = files(
  'widgets/about.vala',
  'widgets/auth.vala',
  'widgets/loadable.vala',
  'widgets/main-content.vala',

  'application.vala',
  'enums.vala',
  'main.vala',
  'utils.vala',
  'window.vala',
)

if get_option('with_webkit')
  vala_sources += files('widgets/webkit/webkit-auth.vala')
endif

sources = [
  vapi_sources,
  vala_sources,
  blueprints,
  resources,
]

executable(
  meson.project_name(),
  sources,
  include_directories: config_h_dir,
  link_args: ['-lm'],
  dependencies: dependencies,
  install: true,
)

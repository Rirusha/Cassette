vapi_sources = files(
  'config.vapi',
)

vala_sources = files(
  'ui/account/account-button.vala',
  'ui/account/account-info-dialog.vala',

  'ui/about.vala',
  'ui/auth.vala',
  'ui/loadable.vala',
  'ui/main-content.vala',
  'ui/window.vala',

  'application.vala',
  'devel-action-group.vala',
  'enums.vala',
  'main.vala',
  'utils.vala',
)

if get_option('with_webkit')
  vala_sources += files('ui/webkit/webkit-auth.vala')
endif

sources = [
  vapi_sources,
  vala_sources,
  resources,
]

executable(
  meson.project_name(),
  sources,
  include_directories: config_h_dir,
  dependencies: dependencies,
  install: true,
)

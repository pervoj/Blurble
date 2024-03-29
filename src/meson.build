sources = [
  'application.vala',
  'window.vala',
  'welcome-page.vala',
  'game-page.vala',
  'result-page.vala',
  'help-page.vala',
  'grid.vala',
  'cell.vala',
  'game-controller.vala',
  'keyboard.vala',
  'key.vala',
  'data.vala',
  'data-parser.vala',
]


blueprints_src = [
  'window.blp',
  'welcome-page.blp',
]


dependencies = [
  dependency('libadwaita-1', version: '>= 1.0'),
  cc.find_library('m', required: true),
]


blueprints_ui = []
blueprints_vala = []
foreach b : blueprints_src
  blueprints_ui += b.replace('.blp', '.ui')
  blueprints_vala += b + '.vala'
endforeach


blueprints = custom_target('blueprints',
  input: blueprints_src,
  output: blueprints_ui,
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTDIR@', '@CURRENT_SOURCE_DIR@', '@INPUT@']
)


sources += custom_target('blueprints_hack',
  input: blueprints,
  output: blueprints_vala,
  command: [find_program('touch'), '@OUTPUT@']
)


sources += configure_file(
  input: 'constants.vala.in',
  output: 'constants.vala',
  configuration: config_data
)


sources += gnome.compile_resources('resources',
  configure_file(
    input: '@0@.gresource.xml.in'.format(meson.project_name()),
    output: '@0@.gresource.xml'.format(meson.project_name()),
    configuration: config_data
  ),
  c_name: meson.project_name(),
  dependencies: blueprints
)


executable(meson.project_name(), sources,
  vala_args: [
    '--target-glib=2.50',
    '--gresourcesdir=src/',
  ],
  dependencies: dependencies,
  install: true,
)

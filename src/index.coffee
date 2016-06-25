###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

FS = require 'fs'
Temp = require 'temp'
SpawnSync = require 'spawn-sync'

CreateFileError = require './errors/CreateFileError'
ReadFileError = require './errors/ReadFileError'
RemoveFileError = require './errors/RemoveFileError'
LaunchEditorError = require './errors/LaunchEditorError'

class ExternalEditor
  @edit: (text = '') ->
    editor = new ExternalEditor(text)
    editor.run()
    editor.cleanup()
    editor.text

  @CreateFileError: CreateFileError
  @ReadFileError: ReadFileError
  @RemoveFileError: RemoveFileError
  @LaunchEditorError: LaunchEditorError

  text: ''
  temp_file: undefined
  editor:
    bin: undefined
    args: []

  constructor: (@text = '') ->
    @determineEditor()
    @createTemporaryFile()

  run: =>
    @launchEditor()
    @readTemporaryFile()

  cleanup: =>
    @removeTemporaryFile()

  determineEditor: =>
    ed = if /^win/.test process.platform then 'notepad' else 'vim'
    editor = process.env.VISUAL or process.env.EDITOR or ed
    args = editor.split /\s+/
    @bin = args.shift()
    @args = args

  createTemporaryFile: =>
    try
      @temp_file = Temp.path()
      FS.writeFileSync @temp_file, @text
    catch e
      throw new CreateFileError e

  readTemporaryFile: =>
    try
      @text = FS.readFileSync(@temp_file).toString()
    catch e
      throw new ReadFileError e

  removeTemporaryFile: =>
    try
      FS.unlinkSync(@temp_file)
    catch e
      throw new RemoveFileError e

  launchEditor: =>
    try
      SpawnSync @bin, @args.concat([@temp_file]), stdio: 'inherit'
    catch e
      throw new LaunchEditorError e

module.exports = ExternalEditor

###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

FS = require 'fs'
Temp = require 'tmp'
SpawnSync = require('child_process').spawnSync
Spawn = require('child_process').spawn
IConvLite = require 'iconv-lite'
ChatDet = require 'chardet'

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

  @editAsync: (text = '', callback) ->
    editor = new ExternalEditor(text)
    editor.runAsync (error_run, text) ->
      if not error_run
        try
          editor.cleanup()
          setImmediate(callback, null, text) if typeof callback is 'function'
        catch error_cleanup
          setImmediate(callback, error_cleanup, null) if typeof callback is 'function'
      else
        setImmediate(callback, error_run, null) if typeof callback is 'function'


  @CreateFileError: CreateFileError
  @ReadFileError: ReadFileError
  @RemoveFileError: RemoveFileError
  @LaunchEditorError: LaunchEditorError

  text: ''
  temp_file: undefined
  editor:
    bin: undefined
    args: []
  last_exit_status: undefined

  constructor: (@text = '') ->
    @determineEditor()
    @createTemporaryFile()

  run: =>
    @launchEditor()
    @readTemporaryFile()

  runAsync: (callback) =>
    try
      @launchEditorAsync =>
        try
          @readTemporaryFile()
          setImmediate(callback, null, @text) if typeof callback is 'function'
        catch error_read
          setImmediate(callback, error_read, null) if typeof callback is 'function'
    catch error_launch
      setImmediate(callback, error_launch, null) if typeof callback is 'function'

  cleanup: =>
    @removeTemporaryFile()

  determineEditor: =>
    ed = if /^win/.test process.platform then 'notepad' else 'vim'
    editor = process.env.VISUAL or process.env.EDITOR or ed
    args = editor.split /\s+/
    @editor.bin = args.shift()
    @editor.args = args

  createTemporaryFile: =>
    try
      @temp_file = Temp.tmpNameSync {}
      FS.writeFileSync @temp_file, @text, encoding: 'utf8'
    catch e
      throw new CreateFileError e

  readTemporaryFile: =>
    try
      buffer = FS.readFileSync(@temp_file)
      return @text = '' unless buffer.length
      encoding = ChatDet.detect buffer
      @text = IConvLite.decode buffer, encoding
    catch e
      throw new ReadFileError e

  removeTemporaryFile: =>
    try
      FS.unlinkSync(@temp_file)
    catch e
      throw new RemoveFileError e

  launchEditor: =>
    try
      run = SpawnSync @editor.bin, @editor.args.concat([@temp_file]), stdio: 'inherit'
      @last_exit_status = run.status
    catch e
      throw new LaunchEditorError e

  launchEditorAsync: (callback) =>
    try
      child_process = Spawn @editor.bin, @editor.args.concat([@temp_file]), stdio: 'inherit'
      child_process.on 'exit', (code) =>
        @last_exit_status = code
        callback() if typeof callback is 'function'
    catch e
      throw new LaunchEditorError e

module.exports = ExternalEditor

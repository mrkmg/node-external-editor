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
    editor.runAsync (error_run, response) ->
      if not error_run
        try
          editor.cleanup()
        catch error_cleanup
          callback(error_cleanup) if typeof callback is 'function'
        callback(null, response)
      else
        callback(error_run) of typeof callback is 'function'


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

  runAsync: (callback) =>
    try
      @launchEditorAsync =>
        try
          @readTemporaryFile()
          callback(null, @text) if typeof callback is 'function'
        catch error_read
          callback(error_read) if typeof callback is 'function'
    catch error_launch
      callback(error_launch) if typeof callback is 'function'

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
      SpawnSync @bin, @args.concat([@temp_file]), stdio: 'inherit'
    catch e
      throw new LaunchEditorError e

  launchEditorAsync: (callback) =>
    try
      child_process = Spawn @bin, @args.concat([@temp_file]), stdio: 'inherit'
      child_process.on 'exit', -> callback() if typeof callback is 'function'
    catch e
      throw new LaunchEditorError e

module.exports = ExternalEditor

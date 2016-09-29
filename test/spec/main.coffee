assert = require('chai').assert
readFileSync = require('fs').readFileSync
ExternalEditor = require('../../src')

describe 'main', ->
  before ->
    @previous_visual = process.env.VISUAL
    process.env.VISUAL = 'truncate --size 1'

  beforeEach ->
    @editor = new ExternalEditor 'XXX'

  afterEach ->
    @editor.cleanup()

  after ->
    process.env.VISUAL = @previous_visual

  it 'convenience method ".edit"', ->
    text = ExternalEditor.edit 'XXX'
    assert.equal text, 'X'

  it 'convenience method ".editAsync"', (cb) ->
    ExternalEditor.editAsync 'XXX', (e, text) ->
      assert.equal text, 'X'
      cb()

  it 'writes original text to file', ->
    contents = readFileSync this.editor.temp_file
    assert.equal contents, 'XXX'

  it 'run() returns correctly', ->
    text = @editor.run()
    assert.equal text, 'X'

  it 'runAsync() callbacks correctly', (cb) ->
    @editor.runAsync (e, text) ->
      assert.equal text, 'X'
      cb()

  it 'run() returns text same as editor.text', ->
    text = @editor.run()
    assert.equal text, @editor.text

  it 'runAsync() callback text same as editor.text', (cb) ->
    @editor.runAsync (e, text) =>
      assert.equal text, @editor.text
      cb()

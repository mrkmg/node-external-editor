assert = require('chai').assert
readFileSync = require('fs').readFileSync
writeFileSync = require('fs').writeFileSync
IConvLite = require 'iconv-lite'
ExternalEditor = require('../../src')

testingInput = 'aAbBcCdDeEfFgG'
expectedResult = 'aAbBcCdDeE'

describe 'main', ->
  before ->
    @previous_visual = process.env.VISUAL
    process.env.VISUAL = 'truncate --size 10'

  beforeEach ->
    @editor = new ExternalEditor testingInput

  afterEach ->
    @editor.cleanup()

  after ->
    process.env.VISUAL = @previous_visual

  it 'convenience method ".edit"', ->
    text = ExternalEditor.edit testingInput
    assert.equal text, expectedResult

  it 'convenience method ".editAsync"', (cb) ->
    ExternalEditor.editAsync testingInput, (e, text) ->
      assert.equal text, expectedResult
      cb()

  it 'writes original text to file', ->
    contents = readFileSync @editor.temp_file
    assert.equal contents, testingInput

  it 'run() returns correctly', ->
    text = @editor.run()
    assert.equal text, expectedResult
    assert.equal @editor.last_exit_status, 0

  it 'runAsync() callbacks correctly', (cb) ->
    ed = @editor
    @editor.runAsync (e, text) ->
      assert.equal text, expectedResult
      assert.equal ed.last_exit_status, 0
      cb()

  it 'run() returns text same as editor.text', ->
    text = @editor.run()
    assert.equal text, @editor.text

  it 'runAsync() callback text same as editor.text', (cb) ->
    @editor.runAsync (e, text) =>
      assert.equal text, @editor.text
      cb()

describe 'invalid exit code', ->

  beforeEach ->
    @editor = new ExternalEditor testingInput
    @editor.editor.bin = "bash"
    @editor.editor.args = ["-c", "exit 1"]

  afterEach ->
    @editor.cleanup()

  it 'run()', ->
    @editor.run()
    assert.equal @editor.last_exit_status, 1

  it 'runAsync()', (cb) ->
    @editor.runAsync =>
      assert.equal @editor.last_exit_status, 1
      cb()

describe 'charsets', ->
  before ->
    @previous_visual = process.env.VISUAL
    process.env.VISUAL = 'true'

  beforeEach ->
    @editor = new ExternalEditor 'XXX'

  afterEach ->
    @editor.cleanup()

  after ->
    process.env.VISUAL = @previous_visual

  it 'empty', ->
    writeFileSync(@editor.temp_file, '')
    text = @editor.run()
    assert.equal text, ''

  it 'utf8', ->
    writeFileSync(@editor.temp_file, IConvLite.encode('काचं शक्नोम्यत्तुम् । नोपहिनस्ति माम् ॥', 'utf8'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, 'काचं शक्नोम्यत्तुम् । नोपहिनस्ति माम् ॥'

  it 'utf16', ->
    writeFileSync(@editor.temp_file, IConvLite.encode('काचं शक्नोम्यत्तुम् । नोपहिनस्ति माम् ॥', 'utf16'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, 'काचं शक्नोम्यत्तुम् । नोपहिनस्ति माम् ॥'

  it 'win1252', ->
    writeFileSync(@editor.temp_file, IConvLite.encode('Testing 1 2 3 ! @ #', 'win1252'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, 'Testing 1 2 3 ! @ #'

  it 'Big5', ->
    writeFileSync(@editor.temp_file, IConvLite.encode('能 脊 胼 胯 臭 臬 舀 舐 航 舫 舨 般 芻 茫 荒 荔', 'Big5'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, '能 脊 胼 胯 臭 臬 舀 舐 航 舫 舨 般 芻 茫 荒 荔'


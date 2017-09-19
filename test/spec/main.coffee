assert = require('chai').assert
readFileSync = require('fs').readFileSync
writeFileSync = require('fs').writeFileSync
IConvLite = require 'iconv-lite'
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
    contents = readFileSync @editor.temp_file
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
    writeFileSync(@editor.temp_file, IConvLite.encode('abc 123 ‰åþ', 'win1252'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, 'abc 123 ‰åþ'

  it 'Big5', ->
    writeFileSync(@editor.temp_file, IConvLite.encode('一一一一', 'Big5'), encoding: 'binary')
    text = @editor.run()
    assert.equal text, '一一一一'


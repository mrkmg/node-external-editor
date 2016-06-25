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

  it 'writes original text to file', ->
    contents = readFileSync this.editor.temp_file

    assert.equal contents, 'XXX'

  it 'run() returns correctly', ->
    text = @editor.run()

    assert.equal text, 'X'

  it 'returned text same as editor.text', ->
    returned_result = @editor.run()

    assert.equal returned_result, @editor.text


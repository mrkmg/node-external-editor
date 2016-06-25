###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

class ReadFileError extends Error
  message: 'Failed to read temporary file'
  constructor: (@original_error) ->

module.exports = ReadFileError

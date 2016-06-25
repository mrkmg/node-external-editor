###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

class CreateFileError extends Error
  message: 'Failed to create temporary file for editor'
  constructor: (@original_error) ->

module.exports = CreateFileError

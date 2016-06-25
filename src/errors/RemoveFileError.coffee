###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

class RemoveFileError extends Error
  message: 'Failed to cleanup temporary file'
  constructor: (@original_error) ->

module.exports = RemoveFileError

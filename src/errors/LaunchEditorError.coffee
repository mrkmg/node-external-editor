###
  ExternalEditor
  Kevin Gravier <kevin@mrkmg.com>
  MIT
###

class LaunchEditorError extends Error
  message: 'Failed launch editor'
  constructor: (@original_error) ->

module.exports = LaunchEditorError


class LaunchEditorError extends Error
  message: 'Failed launch editor'
  constructor: (@original_error) ->

module.exports = LaunchEditorError

class CentralAZ.UserPortal.Views.ErrorSummary extends Backbone.View
	className: 'ui-widget ui-state-error ui-corner-all'
	template: 'error-summary'
	events:
		'click .close': 'closeClicked'

	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		_.bindAll @

	render: ->
		CentralAZ.UserPortal.Helpers.TemplateManager.get @template, (tmp) =>
			html = Mustache.to_html tmp, @model
			@$el.html html
		@
		
	closeClicked: -> 
		@ev.trigger 'errors:close'
		false

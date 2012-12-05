class CentralAZ.UserPortal.Views.EditEmailAddress extends Backbone.View
	tagName: 'div'
	className: 'edit-email-address'
	template: 'edit-email-address'
	events:
		'click .ea-save': 'saveClicked'
		'click .ea-cancel, .ea-close': 'cancelClicked'

	initialize: (options) ->
		@model = options.model
		@ev = options.ev
		_.bindAll @
		@model.on 'error', @onModelError

	render: -> @fromTemplate()

	saveClicked: ->
		attrs = 
			Address: @$el.find('#email-address').val()
			Active: @$el.find('#active').is ':checked'
		action = if @model.isNew() then 'create' else 'save'
		@ev.trigger "emailAddress:#{action}", @model, attrs
		false

	cancelClicked: ->
		@ev.trigger 'view:cancel'
		false
		
	onClose: ->
		@model.off 'error'
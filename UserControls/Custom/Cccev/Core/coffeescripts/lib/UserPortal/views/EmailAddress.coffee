class CentralAZ.UserPortal.Views.EmailAddress extends Backbone.View
	tagName: 'tr'
	template: 'email-address'
	events: 
		'click .ea-edit': 'editClicked'
		'click .ea-delete': 'deleteClicked'

	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		@parent = options.parent
		_.bindAll @
		@model.on 'change', @onChanged

	render: -> @fromTemplate()
	
	editClicked: (e) ->
		id = $(e.currentTarget).attr('data-id')
		@ev.trigger 'emailAddress:edit', parseInt id
		false

	deleteClicked: ->
		if confirm "Are you sure you want to remove '#{@model.get 'Address'}' from your profile?"
			@ev.trigger 'emailAddress:delete', @model
		false

	# TODO: Events appear to be unbound after an email is deleted. The issue fixes itself after
	# a full re-render (e.g. - go to the edit page then back to index).
	# Additionally, running into some layout issues when toggling an email address' "active" bit.
	onChanged: -> 
		console.log 'changed!'
		@render()
	onClose: -> @model.off 'change'
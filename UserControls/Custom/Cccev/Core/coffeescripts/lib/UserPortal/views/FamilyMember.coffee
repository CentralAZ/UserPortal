class CentralAZ.UserPortal.Views.FamilyMember extends Backbone.View
	tagName: 'tr'
	template: 'family-member'
	events:
		'click .fm-edit': 'editClicked'

	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		@parent = options.parent
		_.bindAll @
		@model.on 'change', @onChanged

	render: -> @fromTemplate()

	editClicked: (e) ->
		id = $(e.currentTarget).attr('data-id')
		@ev.trigger 'familyMember:edit', parseInt id
		false

	onChanged: -> @render()

	onClose: -> @model.off 'change'
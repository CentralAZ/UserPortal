class CentralAZ.UserPortal.Views.CampusSelect extends Backbone.View
	tagName: 'li'
	template: 'campus-select'
	events:
		'click .campus': 'campusSelected'
	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		_.bindAll @
	render: -> @fromTemplate()
	campusSelected: ->
		@ev.trigger 'campus:change', @model
		true
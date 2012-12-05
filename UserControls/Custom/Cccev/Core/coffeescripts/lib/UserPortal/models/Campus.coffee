class CentralAZ.UserPortal.Models.Campus extends Backbone.Model
	idAttribute: 'campusID'
	initialize: (options) ->
		if options.name then @set className: options.name.toLowerCase().replace /\ /g, '-'
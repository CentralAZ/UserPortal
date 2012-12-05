class CentralAZ.UserPortal.Models.EmailAddress extends Backbone.Model
	idAttribute: 'EmailID'
	
	validate: (attrs) ->
		@modelErrors = {}
		pattern = /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
		if typeof attrs.Address isnt 'undefined' and (not attrs.Address or not pattern.test attrs.Address)
				@modelErrors.Address = 'Please enter a valid email address'
		keys = _.keys @modelErrors
		if _.any keys then return @modelErrors
# User Portal application entry point
CentralAZ.UserPortal.Helpers.Bootstrapper = 
	initUserInfo: ->
		events = CentralAZ.UserPortal.Helpers.Events
		personPromise = $.trafficCop 'webservices/custom/cccev/core/UserPortalService.asmx/UserInfo',
			dataType: 'json'
			contentType: 'application/json'
		personPromise.done (data) ->
			# Initialize model
			model = new CentralAZ.UserPortal.Models.User data.d

			# Initialize campus collection
			campuses = new CentralAZ.UserPortal.Models.CampusCollection()
			
			# Pull campus collection from the server asyncronously
			campusPromise = campuses.fetch()
			
			# Bind a function to set Campus field of model upon completion of async request
			campusPromise.done ->
				model.set 
					Campus: campuses.get model.get 'CampusID'
				, silent: true
				campus = model.get 'Campus'
				campus.set selected: true
			
			# This will fall through because campuses will be set later via the completion of the 
			# promise declared above
			CentralAZ.UserPortal.campuses = campuses
			userInfoRouter = new CentralAZ.UserPortal.Routers.UserInfoRouter ev: events, model: model
			Backbone.history.start()
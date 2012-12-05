# Custom common view method that seeks to avoid memory leaks
Backbone.View.prototype.close = ->
	# Remove object from DOM
	@remove()

	# Unbind any events associated with the DOM
	@unbind()

	# If onClose is defined, call it to unbind any nested event listeners
	if typeof @onClose is 'function' then @onClose()

# Common view method to load template from TemplateManager
Backbone.View.prototype.fromTemplate = ->
	CentralAZ.UserPortal.Helpers.TemplateManager.get @template, (tmp) =>
		html = Mustache.to_html tmp, @model.toJSON()
		@$el.html html
	@

Backbone.View.prototype.onModelError = (model, errors) ->
	@ev.trigger 'errors:show', model, errors
	@$el.find("[data-field='#{err}']").addClass 'error' for err of errors
	@

# Overridden Backbone.sync to know work with Arena back end. This is NOT optimal,
# as it will impact other modules on the same page that depend on Backbone to talk
# to the server.
Backbone.sync = (method, model) ->
	isPerson = model instanceof CentralAZ.UserPortal.Models.AbstractPerson
	modelData = model.toJSON()
	methodType = 'POST'
	switch method
		when 'delete'
			path = 'DeleteEmail'
			data = id: model.id
		when 'create'
			if isPerson
				path = 'CreateFamilyMember'
				data = person: modelData
			else
				path = 'CreateEmail'
				data = email: modelData
		when 'update'
			if isPerson and model instanceof CentralAZ.UserPortal.Models.User
				path = 'UpdateUser'
				data = user: modelData
			else if isPerson and model instanceof CentralAZ.UserPortal.Models.FamilyMember
				path = 'UpdateFamilyMember'
				data = person: modelData
			else 
				path = 'UpdateEmail'
				data = email: modelData
		when 'read'
			path = 'UserInfo'
			data = {}
			methodType = 'GET'
		else return console.log method
	
	promise = $.trafficCop "webservices/custom/cccev/core/UserPortalService.asmx/#{path}",
		type: methodType
		dataType: 'json'
		contentType: 'application/json; charset=utf-8'
		data: JSON.stringify data
		
	promise.error (xhr, text, err) ->
		# TODO: Elengantly handle errors that come back display error feedback and...
		#  - if method is 'update', reset back to its previous state and display edit screen (see previousAttributes method)
		#  - if method is 'delete', re-add back to the collection
		#  - if method is 'create', remove from collection and display creation screen
		#  - if method is 'read', ???
		# ** Will need to fire events based on model, method and error so they can be dealt with effectively
		console.log 'Uh oh, server errorz!'
		console.log xhr
		console.log text
		console.log err
	promise

(($) ->
	inProgress = {}
	$.trafficCop = (url, options) ->
		reqOptions = url
		if arguments.length is 2 then reqOptions = $.extend true, options, url: url
		key = JSON.stringify reqOptions
		if inProgress[key] then inProgress[key][i](reqOptions[i]) for i of success: 1, error: 1, complete: 1
		else inProgress[key] = $.ajax(reqOptions).always -> delete inProgress[key]
		inProgress[key]
)(jQuery)
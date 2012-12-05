CentralAZ.UserPortal.Helpers.TemplateManager = 
	# Hash to cache templates by name
	templates: {}
	get: (id, callback) ->
		# If it's in the cache, return it. Don't bother fetching it again
		if @templates[id] then return callback.call @, @templates[id]
		url = "usercontrols/custom/cccev/core/templates/#{id}.html"
		
		# Use Traffic Cop jQuery plugin to prevent race conditions whilst rapidly
		# loading a group of views that might use the same template
		promise = $.trafficCop url

		# On completion, cache the template for future use and call back to the caller
		promise.done (template) =>
			@templates[id] = template
			callback.call @, template

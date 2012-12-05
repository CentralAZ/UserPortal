class CentralAZ.UserPortal.Models.CampusCollection extends Backbone.Collection
	model: CentralAZ.UserPortal.Models.Campus

	comparator: (campus) -> campus.get 'campusID'

	url: -> 'webservices/custom/cccev/web2/campusservice.asmx/GetCampusList'

	# Overridden Backbone.Collection.fetch method. Might be preferable to overriding Backbone.sync
	fetch: (options) ->
		promise = $.trafficCop @url(),
			contentType: 'application/json'
			dataType: 'json'
		promise.done (data) =>
			campuses = data.d
			@add campus for campus in campuses
		promise
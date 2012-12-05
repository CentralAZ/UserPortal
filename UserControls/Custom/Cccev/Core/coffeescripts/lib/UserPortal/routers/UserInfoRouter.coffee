class CentralAZ.UserPortal.Routers.UserInfoRouter extends Backbone.Router
	routes:
		'': 'index'
		'*options': 'index'
	initialize: (options) ->
		@presenter = new CentralAZ.UserPortal.Presenters.UserPortalPresenter options
		@ev = options.ev
		_.bindAll @
	index: -> @presenter.index()
class CentralAZ.UserPortal.Views.Index extends Backbone.View
	tagName: 'div'
	className: 'user-details'
	template: 'user-info'
	#childTemplates: ['address']
	events:
		'click .edit, .campus': 'editClicked'
		'click .ea-add': 'emailAddClicked'
		'click .fm-add': 'familyAddClicked'

	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		@family = @model.get 'Family'
		@emails = @model.get 'EmailAddresses'
		@initFamilyMembers()
		@initEmailAddresses()
		_.bindAll @
		@family.on 'add', @familyMemberAdded
		@emails.on 'add', @emailAdded
		@emails.on 'remove', @emailRemoved

	render: ->
		CentralAZ.UserPortal.Helpers.TemplateManager.get @template, (tmp) =>
			html = Mustache.to_html tmp, @model.toJSON()
			@$el.html html
			@onRenderComplete()
		@

	onRenderComplete: ->
		@renderChildren @familyViews, '#family-members tbody'
		@renderChildren @emailViews, '#email-addresses tbody'
		# Silly hack to prevent JS errors when Campus has not been appended to model yet.
		timer = setInterval =>
			campus = @model.get 'Campus'
			if campus
				campusView = new CentralAZ.UserPortal.Views.Campus ev: @ev, model: @model.get 'Campus'
				@$el.find('.avatar').append campusView.render().$el
				clearInterval timer
		, 10


	renderChildren: (array, selector) ->
		$container = @$el.find(selector)
		_.each array, (view) ->
			$container.append view.render().$el
			#view.delegateEvents()

	editClicked: -> 
		@ev.trigger 'user:edit'
		false

	emailAddClicked: ->
		@ev.trigger 'emailAddress:new'
		false

	familyAddClicked: ->
		@ev.trigger 'familyMember:new'
		false

	onClose: -> 
		_.each @familyViews, (view) -> view.close()
		_.each @emailViews, (view) -> view.close()
		@emails.off 'add remove'
		@family.off 'add'

	initFamilyMembers: ->
		@familyViews = []
		@family.each (fm) =>
			@familyViews.push new CentralAZ.UserPortal.Views.FamilyMember ev: @ev, model: fm, parent: @

	initEmailAddresses: ->
		@emailViews = []
		@emails.each (email) => 
			@emailViews.push new CentralAZ.UserPortal.Views.EmailAddress ev: @ev, model: email, parent: @

	familyMemberAdded: (familyMember) ->
		@familyViews.push new CentralAZ.UserPortal.Views.FamilyMember ev: @ev, model: familyMember, parent: @
		@render()

	emailAdded: (email) ->
		@emailViews.push new CentralAZ.UserPortal.Views.EmailAddress ev: @ev, model: email, parent: @
		@render()
		
	emailRemoved: (email) ->
		view = _.select @emailViews, (v) => v.model.get 'EmailID' is email.get 'EmailID'
		if view.length > 0 then @emailViews.pop view[0]
		@render()

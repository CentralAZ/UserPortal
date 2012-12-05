class CentralAZ.UserPortal.Presenters.UserPortalPresenter
	container: '#user-portal'
	constructor: (options) ->
		@ev = options.ev
		@model = options.model
		_.bindAll @
		@bindAppEvents()
		@bindModelEvents()

	bindAppEvents: ->
		@ev.on 'view:cancel', @closeModal
		@ev.on 'errors:show', @showErrorSummary
		@ev.on 'errors:close', @clearErrors

		@ev.on 'user:view', @index
		@ev.on 'user:edit', @editUser
		@ev.on 'user:save', @saveUser

		@ev.on 'emailAddress:new', @newEmailAddress
		@ev.on 'emailAddress:create', @createEmailAddress
		@ev.on 'emailAddress:edit', @editEmailAddress
		@ev.on 'emailAddress:delete', @deleteEmailAddress

		@ev.on 'familyMember:new', @newFamilyMember
		@ev.on 'familyMember:create', @createFamilymember
		@ev.on 'familyMember:edit', @editFamilyMember
		@ev.on 'familyMember:save emailAddress:save', @saveModel

	bindModelEvents: ->
		@model.on 'change:CampusID', @setSelectedCampus
		@model.on 'change:Birthdate', @model.displayDate
		@model.on 'change:Gender', @model.displayGender
		@model.get('Family').forEach (fm) ->
			fm.on 'change:Birthdate', fm.displayDate
			fm.on 'change:Gender', fm.displayGender

	showView: (view) ->
		if @currentView then @currentView.close()
		if @modal then @modal.close()
		@currentView = view
		@currentView.render().$el.appendTo $('#user-portal-container')
		@clearErrors()

	showModalView: (view) ->
		if @modal then @modal.close()
		@modal = view
		@modal.render().$el.hide().appendTo($('#user-portal-container')).fadeIn()
		@clearErrors()

	showErrorSummary: (model, errors) ->
		if @errorSummary then @errorSummary.close()
		messages = []
		messages.push message: err for err in _.values errors
		m = errors: messages
		@errorSummary = new CentralAZ.UserPortal.Views.ErrorSummary ev: @ev, model: m
		@errorSummary.render().$el.hide().appendTo $('#user-portal-container')
		@errorSummary.$el.fadeIn()

	closeModal: -> 
		if @modal then @modal.$el.fadeOut 'normal', => @modal.close()
		@clearErrors()

	clearErrors: -> if @errorSummary then @errorSummary.close()

	index: ->
		index = new CentralAZ.UserPortal.Views.Index ev: @ev, model: @model
		@showView index
		
	editUser: ->
		edit = new CentralAZ.UserPortal.Views.Edit ev: @ev, model: @model
		@showView edit

	saveUser: (model, attrs) ->
		promise = model.save attrs
		if promise
			@showSpinner()
			promise.done => @hideSpinner()
			@ev.trigger 'user:view'

	newFamilyMember: ->
		fm = new CentralAZ.UserPortal.Models.FamilyMember  LastName: @model.get 'LastName'
		familymemberView = new CentralAZ.UserPortal.Views.EditFamilyMember ev: @ev, model: fm
		@showModalView familymemberView

	createFamilymember: (model, attrs) ->
		promise = model.save attrs
		if promise
			@showSpinner()
			@closeModal()
			promise.done (res) =>
				family = @model.get 'Family'
				family.add model
				model.set PersonID: res.d
				@hideSpinner()

	editFamilyMember: (id) ->
		family = @model.get 'Family'
		fm = family.get id
		editFm = new CentralAZ.UserPortal.Views.EditFamilyMember ev: @ev, model: fm
		@showModalView editFm

	newEmailAddress: ->
		email = new CentralAZ.UserPortal.Models.EmailAddress()
		emailView = new CentralAZ.UserPortal.Views.EditEmailAddress ev: @ev, model: email
		@showModalView emailView

	createEmailAddress: (model, attrs) ->
		promise = model.save attrs
		if promise
			@showSpinner()
			@closeModal()
			promise.done (res) =>
				emails = @model.get 'EmailAddresses'
				emails.add model
				model.set EmailID: res.d
				@hideSpinner()

	editEmailAddress: (id) ->
		email = @model.get('EmailAddresses').get id
		emailView = new CentralAZ.UserPortal.Views.EditEmailAddress ev: @ev, model: email
		@showModalView emailView

	deleteEmailAddress: (email) ->
		emailList = @model.get 'EmailAddresses'
		emailList.remove email
		email.destroy()
		@ev.trigger 'user:view'

	saveModel: (model, attrs) ->
		promise = model.save attrs
		if promise
			@showSpinner()
			@closeModal()
			promise.done => @hideSpinner()

	# Listen for changes to user's Campus field and keep the collection of Campuses selected status in sync
	setSelectedCampus: (user) ->
		newID = user.get 'CampusID'
		CentralAZ.UserPortal.campuses.forEach (campus) ->
			id = campus.get 'campusID'
			if id is newID then campus.set selected: true else campus.set selected: false

	showSpinner: ->
		if @spinner then return
		else
			@spinner = new CentralAZ.UserPortal.Views.Spinner()
			@spinner.render().$el.hide().appendTo('#user-portal-container').fadeIn()
	
	hideSpinner: ->
		if @spinner then @spinner.$el.fadeOut 'normal', => 
			@spinner.close()
			@spinner = null


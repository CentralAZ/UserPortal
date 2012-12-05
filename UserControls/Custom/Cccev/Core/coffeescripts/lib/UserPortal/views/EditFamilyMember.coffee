class CentralAZ.UserPortal.Views.EditFamilyMember extends Backbone.View
	tagName: 'div'
	className: 'edit-family-member'
	template: 'edit-family-member'
	events:
		'click .fm-save': 'saveClicked'
		'click .fm-cancel, .fm-close': 'cancelClicked'
	initialize: (options) ->
		@ev = options.ev
		@model = options.model
		_.bindAll @
		@model.on 'error', @onModelError

	render: ->
		CentralAZ.UserPortal.Helpers.TemplateManager.get @template, (tmp) =>
			html = Mustache.to_html tmp, @model.toJSON()
			@$el.html html
			@onRenderComplete()
		@

	onRenderComplete: ->
		@$el.find('.fm-gender').buttonset()
		@$el.find('#birthdate').datepicker
			showOn: 'button'
			buttonImage: 'usercontrols/custom/cccev/core/images/calendar-icon.png'
			buttonImageOnly: true
			changeMonth: true
			changeYear: true

	saveClicked: ->
		birthdate = new Date Date.parse @$el.find('#birthdate').val()
		attrs = 
			FirstName: @$el.find('#first-name').val()
			LastName: @$el.find('#last-name').val()
			Birthdate: birthdate.getTime()
			Gender: @$el.find('[name="gender"]:checked').val() or null
		action = if @model.isNew() then 'create' else 'save'
		@ev.trigger "familyMember:#{action}", @model, attrs
		false
		
	cancelClicked: ->
		@ev.trigger 'view:cancel'
		false
	
	onClose: -> @model.off 'error'
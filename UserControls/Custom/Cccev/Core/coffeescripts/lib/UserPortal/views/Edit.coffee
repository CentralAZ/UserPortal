class CentralAZ.UserPortal.Views.Edit extends Backbone.View
    tagName: 'div'
    className: 'edit-details'
    template: 'edit-user-info'
    #childTemplates: ['address']
    events:
        'click .user-save': 'saveClicked'
        'click .cancel': 'cancelClicked'
        'mouseenter #address': 'showTooltip'
        'mouseleave #address': 'hideTooltip'

    initialize: (options) ->
        @ev = options.ev
        @model = options.model
        @initChildViews()
        @selectedCampus = CentralAZ.UserPortal.campuses.get @model.get 'CampusID'
        _.bindAll @
        @ev.on 'campus:change', @campusChanged
        @ev.on 'view:rendered', @renderFinished
        @model.on 'error', @onModelError

    render: -> 
        CentralAZ.UserPortal.Helpers.TemplateManager.get @template, (tmp) =>
            json = @model.toJSON()
            json.Campus = if @model.get('Campus') then @model.get('Campus').toJSON() else null
            html = Mustache.to_html tmp, json
            @$el.html html
            @onRenderComplete()
        @

    initChildViews: ->
        @childViews = []
        CentralAZ.UserPortal.campuses.forEach (campus) =>
            view = new CentralAZ.UserPortal.Views.CampusSelect ev: @ev, model: campus
            @childViews.push view

    onRenderComplete: ->
        $ul = @$el.find('#campus-picker')
        lastID = CentralAZ.UserPortal.campuses.last().get 'campusID'
        _.each @childViews, (view) =>
            $ul.append view.render().$el
            id = view.model.get 'campusID'
            if id is lastID then @bindUi()

    # Any post-rendering mojo happens in here (e.g. - wiring up jQueryUI widgets, etc)
    bindUi: ->
        $ul = @$el.find('#campus-picker')
        @$el.find('#birthdate').datepicker
            showOn: 'button'
            buttonImage: 'usercontrols/custom/cccev/core/images/calendar-icon.png'
            buttonImageOnly: true
            changeMonth: true
            changeYear: true
        @$el.find('#gender').buttonset()
        @$el.find('.phone-options').buttonset()
        # Super ugly hack to force jQueryUI into submission and avoid race conditions in async UI
        timer = setInterval ->
            if not $ul.find('label.campus').hasClass 'ui-widget' then $ul.buttonset()
            else clearInterval timer
        , 10

    campusChanged: (campus) -> @selectedCampus = campus

    saveClicked: ->
        birthdate = new Date Date.parse @$el.find('#birthdate').val()
        attrs = 
            FirstName: @$el.find('#first-name').val()
            LastName: @$el.find('#last-name').val()
            Birthdate: birthdate.getTime()
            Gender: @$el.find('[name="gender"]:checked').val() or null
            HomePhone: @$el.find('#home-phone').val()
            IsHomeUnlisted: @$el.find('#home-unlisted').is(':checked')
            IsHomeSms: @$el.find('#home-sms').is(':checked')
            MobilePhone: @$el.find('#mobile-phone').val()
            IsMobileUnlisted: @$el.find('#mobile-unlisted').is(':checked')
            IsMobileSms: @$el.find('#mobile-sms').is(':checked')
            Campus: @selectedCampus
            CampusID: @selectedCampus.get 'campusID'
        @ev.trigger 'user:save', @model, attrs
        false

    cancelClicked: -> 
        @ev.trigger 'user:view'
        false

    showTooltip: (e) ->
        $(e.currentTarget).find('.tool-tip').fadeIn()
        false

    hideTooltip: (e) ->
        $(e.currentTarget).find('.tool-tip').fadeOut()
        false

    onClose: -> 
        @ev.off 'campus:change'
        @ev.off 'view:rendered'
        @model.off 'error'
        _.each @childViews, (view) -> view.close()

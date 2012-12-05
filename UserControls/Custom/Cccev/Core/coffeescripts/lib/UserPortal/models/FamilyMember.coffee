class CentralAZ.UserPortal.Models.FamilyMember extends CentralAZ.UserPortal.Models.AbstractPerson
	idAttribute: 'PersonID'
	initialize: (options) -> 
		if options.Birthdate then @displayDate()
		if options.Gender then @displayGender()

	validate: (attrs) ->
		@modelErrors = {}
		if typeof attrs.FirstName isnt 'undefined' and not attrs.FirstName
			@modelErrors.FirstName = 'First name is required'
		if typeof attrs.LastName isnt 'undefined' and not attrs.LastName
			@modelErrors.LastName = 'Last name is required'
		if typeof attrs.Birthdate isnt 'undefined' and not attrs.Birthdate
			@modelErrors.Birthdate = 'Birthdate is required'
		if typeof attrs.Gender isnt 'undefined' and not attrs.Gender
			@modelErrors.Gender = 'Gender is required'
		keys = _.keys @modelErrors
		if _.any keys then return @modelErrors
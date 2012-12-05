class CentralAZ.UserPortal.Models.User extends CentralAZ.UserPortal.Models.AbstractPerson
    idAttribute: 'PersonID'
    initialize: (options) ->
        if not options then return
        if options.Birthdate then @displayDate()
        if options.EmailAddresses
            # Set fields silently here to avoid triggering validation
            @set 
                EmailAddresses: new CentralAZ.UserPortal.Models.EmailAddressCollection options.EmailAddresses
            , silent: true
        if options.Family
            # Set fields silently here to avoid triggering validation
            @set 
                Family: new CentralAZ.UserPortal.Models.FamilyMemberCollection options.Family
            , silent: true
        if options.Gender then @displayGender()

    validate: (attrs) ->
        @modelErrors = {}
        phonePattern = /^(?:\([2-9]\d{2}\)\ ?|[2-9]\d{2}(?:\-?|\ ?))[2-9]\d{2}[- ]?\d{4}$/
        if typeof attrs.FirstName isnt 'undefined' and not attrs.FirstName
            @modelErrors.FirstName = 'Please enter your first name'

        if typeof attrs.LastName isnt 'undefined' and not attrs.LastName
            @modelErrors.LastName = 'Please enter your last name'

        if typeof attrs.HomePhone isnt 'undefined' and (not attrs.HomePhone or not phonePattern.test attrs.HomePhone)
            @modelErrors.HomePhone = 'Please enter a valid home phone number'

        if typeof attrs.AddressLine1 isnt 'undefined' and not attrs.AddressLine1
            @modelErrors.AddressLine1 = 'Please enter your address'

        if typeof attrs.City isnt 'undefined' and not attrs.City
            @modelErrors.City = 'Please enter your city'

        if typeof attrs.State isnt 'undefined' and not attrs.State
            @modelErrors.State = 'Please enter your state'

        if typeof attrs.ZipCode isnt 'undefined' and not attrs.ZipCode
            @modelErrors.ZipCode = 'Please enter your zip code'

        if typeof attrs.Birthdate isnt 'undefined' and not /^-{0,1}\d+$/.test attrs.Birthdate
            @modelErrors.Birthdate = 'Please enter your birthdate'

        if typeof attrs.Gender isnt 'undefined' and not attrs.Gender
            @modelErrors.Gender = 'Please select your gender'

        if typeof attrs.CampusID isnt 'undefined' and not attrs.CampusID
            @modelErrors.Campus = 'Please select your campus'
            
        keys = _.keys @modelErrors
        if _.any keys then return @modelErrors
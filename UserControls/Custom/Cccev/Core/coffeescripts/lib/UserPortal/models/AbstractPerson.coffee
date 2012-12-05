# Base class for User and FamilyMember to inherit that contains common functionality
# Named with an 'A' so it gets declared in final JS document before its concrete classes
class CentralAZ.UserPortal.Models.AbstractPerson extends Backbone.Model
	displayDate: ->
		# For viewing purposes we need to create DisplayDate and Age properties
		birthdate = new Date @get 'Birthdate'
		nulldate = new Date Date.parse '1/1/1900'

		# If birthdate is unknown, set display date and Age default values accordingly
		if birthdate.getTime() is nulldate.getTime()
			return @set { DisplayDate: 'Unknown', Age: '?' }, { silent: true }
		
		# DisplayDate needed for datepicker fields that require mm/dd/yyyy date format
		# Set fields silently to avoid triggering validation
		@set 
			DisplayDate: "#{birthdate.getMonth() + 1}/#{birthdate.getDate()}/#{birthdate.getFullYear()}"
		, silent: true

		# Calculate age based on birthdate
		today = new Date()
		age = today.getFullYear() - birthdate.getFullYear()
		month =  today.getMonth() - birthdate.getMonth()
		if month < 0 or (month is 0 and today.getDate() < birthdate.getDate()) then age--
		
		# Age needed to display 'x years old' on various views
		# Set fields silently to avoid triggering validation
		@set 
			Age: age
		, silent: true

	displayGender: ->
		gender = @get 'Gender'
		# Set fields silently here to avoid triggering validation
		@set
			isMale: gender is 'Male'
			isFemale: gender is 'Female'
		, silent: true
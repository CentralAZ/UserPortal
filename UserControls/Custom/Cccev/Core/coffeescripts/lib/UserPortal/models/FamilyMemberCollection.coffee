class CentralAZ.UserPortal.Models.FamilyMemberCollection extends Backbone.Collection
	model: CentralAZ.UserPortal.Models.FamilyMember
	comparator: (user) -> 
		birthdate = new Date user.get 'Birthdate'
		birthdate.getTime()
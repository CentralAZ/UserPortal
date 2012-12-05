class CentralAZ.UserPortal.Models.EmailAddressCollection extends Backbone.Collection
	model: CentralAZ.UserPortal.Models.EmailAddress
	comparator: (email) -> email.get 'Active'
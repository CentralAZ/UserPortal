<%@ WebService Language="C#" Class="UserPortalService" %>

using System;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Xml.Serialization;
using Arena.Core;
using Arena.Custom.Cccev.DataUtils;
using Arena.Custom.Cccev.FrameworkUtils.FrameworkConstants;
using Arena.DataLayer.Core;
using Arena.Enums;
using Arena.Organization;
using Arena.Utility;
using Attribute = Arena.Core.Attribute;

[Serializable]
public class User
{
    public int PersonID { get; set; }
    public Guid BlobID { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public Email[] EmailAddresses { get; set; }
    public string HomePhone { get; set; }
    public bool IsHomeUnlisted { get; set; }
    public bool IsHomeSms { get; set; }
    public string MobilePhone { get; set; }
    public bool IsMobileUnlisted { get; set; }
    public bool IsMobileSms { get; set; }
    public string AddressLine1 { get; set; }
    public string AddressLine2 { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string ZipCode { get; set; }
    public double Birthdate { get; set; }
    public string Gender { get; set; }
    public int CampusID { get; set; }
    public string[] NewsTopics { get; set; }
    public string Role { get; set; }
    public User[] Family { get; set; }
    public bool IsCurrentUser { get; set; }
}

[Serializable]
public class Email
{
    public int EmailID { get; set; }
    public string Address { get; set; }
    public bool Active { get; set; }
}

/// <summary>
/// TODO: Server-side validation of all models being passed in for data persistence
/// TODO: Harden/finalize data persitence
/// </summary>
[WebService(Namespace = "http://localhost/arena")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
[ScriptService]
[XmlInclude(typeof(User))]
[XmlInclude(typeof(Email))]
public class UserPortalService : WebService 
{
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = true)]
    public User UserInfo()
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return null;
        }

        var currentPerson = ArenaContext.Current.Person;
        var attribute = new Attribute(SystemGuids.WEB_PREFS_NEWS_TOPICS_ATTRIBUTE);
        var family = currentPerson.Family();
        var familyMembers = (from fm in family.FamilyMembersActive
                             let address = fm.Addresses.Any() ? fm.Addresses.PrimaryAddress().Address : new Address()
                             let topics = new PersonAttribute(fm.PersonID, attribute.AttributeId)
                             let homePhone = fm.Phones.FindByType(SystemLookup.PhoneType_Home)
                             let cellPhone = fm.Phones.FindByType(SystemLookup.PhoneType_Cell)
                             orderby fm.BirthDate
                             select new User
                                        {
                                            PersonID = fm.PersonID,
                                            BlobID = new ArenaDataBlob(fm.BlobID).GUID,
                                            FirstName = fm.FirstName,
                                            LastName = fm.LastName,
                                            //Birthdate = (long) (fm.BirthDate - new DateTime(1970, 1, 1)).TotalMilliseconds,
                                            Birthdate = ToJsDate(fm.BirthDate),
                                            Gender = fm.Gender.ToString(),
                                            EmailAddresses = fm.Emails.Select(e => new Email
                                                                                       {
                                                                                           EmailID = e.EmailId,
                                                                                           Address = e.Email,
                                                                                           Active = e.Active
                                                                                       }).ToArray(),
                                            HomePhone = homePhone != null ? homePhone.Number : null,
                                            IsHomeUnlisted = homePhone != null && homePhone.Unlisted,
                                            IsHomeSms = homePhone != null && homePhone.SMSEnabled,
                                            MobilePhone = cellPhone != null ? cellPhone.Number : null,
                                            IsMobileUnlisted = cellPhone != null && cellPhone.Unlisted,
                                            IsMobileSms = cellPhone != null && cellPhone.SMSEnabled,
                                            AddressLine1 = address.StreetLine1,
                                            AddressLine2 = address.StreetLine2,
                                            State = address.State,
                                            City = address.City,
                                            ZipCode = address.PostalCode,
                                            CampusID = fm.Campus != null ? fm.Campus.CampusId : Constants.NULL_INT,
                                            NewsTopics = topics.StringValue.Split(new[] {','}),
                                            Role = fm.FamilyRole.Value,
                                            IsCurrentUser = fm.PersonID == currentPerson.PersonID
                                        }).ToList();

        var currentUser = familyMembers.Single(p => p.PersonID == currentPerson.PersonID);
        familyMembers.Remove(currentUser);
        currentUser.Family = familyMembers.ToArray();
        return currentUser;
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
    public int UpdateUser(User user)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return Constants.NULL_INT;
        }

        try
        {
            var campus = new Campus(user.CampusID);
            var orgID = ArenaContext.Current.Organization.OrganizationID;
            var userName = HttpContext.Current.User.Identity.Name;
            
            var currentPerson = ArenaContext.Current.Person;
            currentPerson.FirstName = user.FirstName;
            currentPerson.LastName = user.LastName;
            currentPerson.BirthDate = new DateTime(1970, 1, 1).AddTicks((long) user.Birthdate * 10000);
            currentPerson.Campus = campus;
            currentPerson.Gender = (Gender) Enum.Parse(typeof (Gender), user.Gender);
            currentPerson.Save(orgID, userName, false);
            
            // TODO: Figure out how updating phones and addresses will work

            var phones = currentPerson.Phones;
            var savedPhone = false;
            var homePhoneType = SystemLookup.PhoneType_Home;
            var mobilePhoneType = SystemLookup.PhoneType_Cell;

            foreach (var phone in phones)
            {
                var phoneTypeGuid = phone.PhoneType.Guid;
                var isHomePhone = phoneTypeGuid == homePhoneType;
                var isMobilePhone = phoneTypeGuid == mobilePhoneType;
                
                // If home phone numbers are not equal
                if (isHomePhone)
                {
                    phone.Number = PersonPhone.FormatPhone(user.HomePhone);
                    phone.SMSEnabled = user.IsHomeSms;
                    phone.Unlisted = user.IsHomeUnlisted;
                    savedPhone = true;
                }
                // If mobile phone numbers are not equal
                else if (isMobilePhone)
                {
                    phone.Number = PersonPhone.FormatPhone(user.MobilePhone);
                    phone.SMSEnabled = user.IsMobileSms;
                    phone.Unlisted = user.IsMobileUnlisted;
                    savedPhone = true;
                }
            }

            if (savedPhone)
            {
                currentPerson.SavePhones(orgID, userName);
            }

            // When a person saves their campus, we set the campus for each of their family members.
            var family = currentPerson.Family().FamilyMembersActive;

            foreach (var fm in family)
            {
                fm.Campus = campus;
                fm.Save(orgID, userName, false);
            }
            
            return currentPerson.PersonID;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return Constants.NULL_INT;
        }
        
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
    public int CreateEmail(Email email)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return Constants.NULL_INT;
        }

        try
        {
            var currentPerson = ArenaContext.Current.Person;
            var userName = ArenaContext.Current.User.Identity.Name;
            var personEmail = new PersonEmail
                                  {
                                      PersonId = currentPerson.PersonID,
                                      Active = email.Active,
                                      AllowBulkMail = true,
                                      Email = email.Address
                                  };
            currentPerson.Emails.Add(personEmail);
            //currentPerson.Save(ArenaContext.Current.Organization.OrganizationID, userName, true);
            currentPerson.SaveEmails(ArenaContext.Current.Organization.OrganizationID, userName);
            return personEmail.EmailId;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return Constants.NULL_INT;
        }
    }
    
    // This method could be invoked like this on the client: 
    /// $.ajax({
    ///     url: 'webservices/custom/cccev/core/personservice.asmx/UpdateUser',
    ///     data: '{ "user": { "FirstName": "Jason", "LastName": "Offutt" } }'
    ///     type: 'POST',
    ///     contentType: 'application/json',
    ///     dataType: 'json',
    ///     success: function(result) {
    /// 	    console.log(result);
    ///     }
    /// });
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
    public int UpdateEmail(Email email)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return Constants.NULL_INT;
        }

        try
        {
            var person = ArenaContext.Current.Person;
            var personEmail = person.Emails.Single(e => e.EmailId == email.EmailID);
            personEmail.Email = email.Address;
            personEmail.Active = email.Active;
            person.SaveEmails(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name);
            return personEmail.EmailId;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return Constants.NULL_INT;
        }
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat =  ResponseFormat.Json, UseHttpGet = false)]
    public bool DeleteEmail(int id)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return false;
        }

        try
        {
            //var currentPerson = ArenaContext.Current.Person;
            //var email = currentPerson.Emails.FirstOrDefault(e => e.EmailId == id);
            //currentPerson.Emails.Remove(email);
            //currentPerson.SaveEmails(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name);
            new PersonEmailData().DeletePersonEmail(id);
            return true;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return false;
        }
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
    public int CreateFamilyMember(User person)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return Constants.NULL_INT;
        }

        try
        {
            var createdBy = HttpContext.Current.User.Identity.Name;
            var currentPerson = ArenaContext.Current.Person;
            var family = currentPerson.Family();
            var org = ArenaContext.Current.Organization;
            var lookupID = org.Settings["CentralAZ.Web.FacebookRegistration.MembershipStatus"];
            var status = new Lookup(int.Parse(lookupID));
            var newPerson = new Person
                             {
                                 RecordStatus = RecordStatus.Pending,
                                 MemberStatus = status,
                                 FirstName = person.FirstName,
                                 LastName = person.LastName,
                                 BirthDate = new DateTime(1970, 1, 1).AddTicks((long) person.Birthdate * 10000),
                                 Gender = (Gender)Enum.Parse(typeof(Gender), person.Gender)
                             };
            
            newPerson.Save(org.OrganizationID, createdBy, false);
            var familyMember = new FamilyMember(family.FamilyID, newPerson.PersonID)
                                   {
                                       FamilyID = family.FamilyID,
                                       FamilyRole = new Lookup(SystemLookup.FamilyRole_Child)
                                   };
            
            familyMember.Save(createdBy);
            return familyMember.PersonID;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return Constants.NULL_INT;
        }
    }
    
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
    public int UpdateFamilyMember(User person)
    {
        if (!HttpContext.Current.Request.IsAuthenticated)
        {
            return Constants.NULL_INT;
        }

        try
        {
            var family = ArenaContext.Current.Person.Family();
            var familyMember = family.FamilyMembersActive.SingleOrDefault(fm => fm.PersonID == person.PersonID);

            if (familyMember == null)
            {
                return Constants.NULL_INT;
            }
            
            familyMember.FirstName = person.FirstName;
            familyMember.LastName = person.LastName;
            familyMember.BirthDate = new DateTime(1970, 1, 1).AddTicks((long) person.Birthdate * 10000);
            familyMember.Gender = (Gender)Enum.Parse(typeof(Gender), person.Gender);
            familyMember.Save(ArenaContext.Current.Organization.OrganizationID, ArenaContext.Current.User.Identity.Name, false);
            return familyMember.PersonID;
        }
        catch (Exception ex)
        {
            LogException(ex);
            return Constants.NULL_INT;
        }
    }
    
    private void LogException(Exception ex)
    {
        new ExceptionHistoryData().AddUpdate_Exception(ex, ArenaContext.Current.Organization.OrganizationID,
                "Cccev.Web", ArenaContext.Current.ServerUrl);
    }
    
    private double ToJsDate(DateTime date)
    {
        var epoch = new DateTime(1970, 1, 1);
        var universalDate = date.ToUniversalTime();
        var timeSpan = universalDate - epoch;
        return timeSpan.TotalMilliseconds;
    }
}
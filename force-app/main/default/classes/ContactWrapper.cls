public inherited sharing class ContactWrapper {
    public String externalId { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String emailAddress { get; set; }
    public Date dateOfBirth { get; set; }
    public Boolean optedOutOfEmail { get; set; }
    public String phone { get; set; }

    public ContactWrapper(Contact contact) {
        this.externalId = contact.External_Id__c;
        this.firstName = contact.FirstName;
        this.lastName = contact.LastName;
        this.emailAddress = contact.Email;
        this.dateOfBirth = contact.Birthdate;
        this.optedOutOfEmail = contact.HasOptedOutOfEmail;
        this.phone = contact.Phone;
    }

    public ContactWrapper(External_Contact__c externalContact) {
        this.externalId = externalContact.External_Id__c;
        this.firstName = externalContact.First_Name__c;
        this.lastName = externalContact.Last_Name__c;
        this.emailAddress = externalContact.Email__c;
        this.dateOfBirth = externalContact.Birthdate__c;
        this.optedOutOfEmail = externalContact.Email_Opt_Out__c;
        this.phone = externalContact.Phone__c;
    }

    public static List<ContactWrapper> parseList(String json) {
        return (List<ContactWrapper>)System.JSON.deserialize(json, List<ContactWrapper>.class);
    }

    public Contact toContact() {
        return new Contact(
            External_Id__c = this.externalId,
            FirstName = this.firstName,
            LastName = this.lastName,
            Email = this.emailAddress,
            Birthdate = this.dateOfBirth,
            HasOptedOutOfEmail = this.optedOutOfEmail,
            Phone = this.phone
        );
    }

    public External_Contact__c toExternalContact() {
        return new External_Contact__c(
            External_Id__c = this.externalId,
            First_Name__c = this.firstName,
            Last_Name__c = this.lastName,
            Email__c = this.emailAddress,
            Birthdate__c = this.dateOfBirth,
            Email_Opt_Out__c = this.optedOutOfEmail,
            Phone__c = this.phone
        );
    }
}

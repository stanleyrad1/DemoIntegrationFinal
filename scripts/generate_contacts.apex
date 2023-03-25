List<Contact> contacts = new List<Contact>();
String formattedNumber;
for (Integer i = 0; i < 25; i++) {
    formattedNumber = String.valueOf(i).leftPad(4, '0');
    contacts.add(new Contact(
            FirstName = 'Tester ' + formattedNumber,
            LastName = 'McTesterson',
            Email = 'test' + i + '@test.com',
            Phone = '(555) 555-' + formattedNumber,
            Birthdate = System.today().addYears(-10-i),
            External_Id__c = formattedNumber
    ));

}
insert contacts;

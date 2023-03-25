/**
 * @description A class that handles REST service operations for Contacts.
 */
public inherited sharing class ContactRestServiceHandler implements Queueable, Database.AllowsCallouts {
    private static final String ENDPOINT_URL = 'https://webhook.site/5462b21b-fc8e-4df1-899d-051f7c225855';
    private static final Integer MAX_TIMEOUT_IN_MILLISECONDS = 120000;
    private static final Integer IS_SUCCESS_CODE = 200;
    private static final Integer MAX_REQUEST_BATCH_SIZE = 100;
    private final List<ContactWrapper> contactWrappers;
    private final Boolean isCreateOperation;

    public ContactRestServiceHandler(List<ContactWrapper> contactWrappers, Boolean isCreateOperation) {
        this.contactWrappers = contactWrappers;
        this.isCreateOperation = isCreateOperation;
    }

    public void execute(QueueableContext queueableContext) {
        ContactRestServiceHandler.sendRequest(contactWrappers, this.isCreateOperation);
    }

    /**
     * @description Sends a request to endpoint asynchronously using Future Method.
     *
     * @param contactIds A set of Contact Ids.
     * @param isCreateOperation A boolean that indicates if the operation is a create or update operation.
     */
    @Future(Callout=true)
    public static void sendRequestAsync(Set<Id> contactIds, Boolean isCreateOperation) {
        List<ContactWrapper> contactWrappers = ContactRestServiceHandler.getContactWrappers(contactIds);
        ContactRestServiceHandler.sendRequest(contactWrappers, isCreateOperation);
    }

    /**
     * @description Enqueues contacts request jobs to endpoint asynchronously using Queueable Class.
     *
     * @param contacts A list of Contact objects.
     * @param isCreateOperation A boolean that indicates if the operation is a create or update operation.
     */
    public static void enqueueRequestJobs(List<Contact> contacts, Boolean isCreateOperation) {
        List<ContactWrapper> batch = new List<ContactWrapper>();
        for (Contact c : contacts) {
            batch.add(new ContactWrapper(c));
            if (batch.size() == MAX_REQUEST_BATCH_SIZE) {
                System.enqueueJob(new ContactRestServiceHandler(batch, isCreateOperation));
                batch = new List<ContactWrapper>();
            }
        }

        if (batch.size() > 0) {
            System.enqueueJob(new ContactRestServiceHandler(batch, isCreateOperation));
        }
    }

    /**
     * @description Retrieves ContactWrapper objects for the specified Contact Ids.
     *
     * @param contactIds A set of Contact Ids.
     *
     * @return A list of ContactWrapper objects.
     */
    private static List<ContactWrapper> getContactWrappers(Set<Id> contactIds) {
        List<ContactWrapper> contactWrappers = new List<ContactWrapper>();
        for (Contact contact : [
                SELECT External_Id__c, FirstName, LastName, Email, Birthdate, Phone, HasOptedOutOfEmail
                FROM Contact
                WHERE Id IN :contactIds
        ]) {
            contactWrappers.add(new ContactWrapper(contact));
        }
        return contactWrappers;
    }

    /**
     * @description Sends a request to the endpoint synchronously.
     *
     * @param contactWrappers A list of ContactWrapper objects.
     * @param isCreateOperation A boolean that indicates if the operation is a create or update operation.
     */
    private static void sendRequest(List<ContactWrapper> contactWrappers, Boolean isCreateOperation) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL);
        request.setMethod(isCreateOperation ? 'POST' : 'PUT');
        request.setTimeout(MAX_TIMEOUT_IN_MILLISECONDS);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setBody(JSON.serialize(contactWrappers));

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != IS_SUCCESS_CODE) {
                System.debug(response);
                System.debug(response.getBody());
            } else {
                // handle successful response
            }
        } catch(Exception e) {
            // Handle exception here or rethrow to higher level
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}

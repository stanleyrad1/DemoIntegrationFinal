@RestResource(UrlMapping='/external_contacts/*')
global without sharing class ContactRestService {
    private static final Integer STATUS_CODE_SERVER_ERROR = 500;
    private static final Integer STATUS_CODE_BAD_REQUEST_ERROR = 400;
    private static final Integer STATUS_CODE_NOT_FOUND_ERROR = 404;
    private static final RestRequest request = RestContext.request;
    private static final RestResponse response = RestContext.response;
    private static final String URL_MAPPING = '/external_contacts/';

    static {
        response.addHeader('Content-Type', 'application/json');
    }

    @HttpGet
    global static void handleGet() {
        try {
            System.debug(request.requestURI);
            String externalId = request.requestURI.substringAfter(URL_MAPPING);
            System.debug(externalId);
            if (String.isNotBlank(externalId) && isValidId(externalId)) {
                response.statusCode = STATUS_CODE_BAD_REQUEST_ERROR;
                throw new RestServiceException('Invalid External Id');
            }

            String query =
                    'SELECT External_Id__c, First_Name__c, Last_Name__c, Email__c, ' +
                            'Birthdate__c, Email_Opt_Out__c, Phone__c ' +
                    'FROM External_Contact__c ' +
                    (String.isNotBlank(externalId) ? 'WHERE External_Id__c = :externalId ' : '') +
                    'LIMIT 200';
            List<External_Contact__c> externalContacts = Database.query(query);
            if (String.isNotBlank(externalId) && externalContacts.isEmpty()) {
                response.statusCode = STATUS_CODE_NOT_FOUND_ERROR;
                throw new RestServiceException('External Contact not found');
            }

            List<ContactWrapper> wrappers = new List<ContactWrapper>();
            for (External_Contact__c externalContact : externalContacts) {
                wrappers.add(new ContactWrapper(externalContact));
            }
            response.responseBody = serializeToBlob(wrappers);
        } catch(Exception e) {
            handleException(e);
        }
    }

    @HttpPost
    global static void handlePost() {
        try {
            List<ContactWrapper> wrappers = ContactWrapper.parseList(request.requestBody.toString());
            List<External_Contact__c> externalContacts = new List<External_Contact__c>();
            for (ContactWrapper wrapper : wrappers) {
                externalContacts.add(wrapper.toExternalContact());
            }
            insert externalContacts;

            response.responseBody = serializeToBlob(externalContacts);
        } catch(Exception e) {
            handleException(e);
        }
    }

    @HttpPut
    global static void handlePut() {
        try {
            List<ContactWrapper> wrappers = ContactWrapper.parseList(request.requestBody.toString());
            List<External_Contact__c> externalContacts = new List<External_Contact__c>();
            for (ContactWrapper wrapper : wrappers) {
                externalContacts.add(wrapper.toExternalContact());
            }

            upsert externalContacts External_Id__c;
            response.responseBody = serializeToBlob(wrappers);
        } catch(Exception e) {
            handleException(e);
        }
    }

    @HttpDelete
    global static void handleDelete() {
        try {
            String externalId = RestContext.request.requestURI.substringAfterLast('/');
            if (String.isNotBlank(externalId) && isValidId(externalId)) {
                response.statusCode = STATUS_CODE_BAD_REQUEST_ERROR;
                throw new RestServiceException('Invalid External Id');
            }

            External_Contact__c externalContact = [
                    SELECT Id
                    FROM External_Contact__c
                    WHERE External_Id__c = :externalId
            ];

            if (externalContact == null) {
                response.statusCode = STATUS_CODE_NOT_FOUND_ERROR;
                throw new RestServiceException('External Contact not found');
            }

            delete externalContact;
        } catch(Exception e) {
            handleException(e);
        }
    }

    public class RestServiceException extends Exception {
    }

    private static Blob serializeToBlob(Object obj) {
        return Blob.valueOf(System.JSON.serialize(obj));
    }

    private static Boolean isValidId(String val) {
        return !val.isNumeric();
    }

    private static void handleException(Exception e) {
        response.statusCode = STATUS_CODE_SERVER_ERROR;
        response.responseBody = serializeToBlob(getError(e.getMessage()));
    }

    private static Map<String, Object> getError(String message) {
        return new Map<String, Object>{
                'status' => 'error',
                'message' => message
        };
    }
}

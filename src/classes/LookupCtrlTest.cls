@isTest
private class LookupCtrlTest {

    @isTest static void test_getRecentRecords() {
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecentRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');

        System.assertEquals(true, response.get('isSuccess'));
    }

    @isTest static void test_getRecordLabel() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecordLabel(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        String objectLabel = String.valueOf(results.get('objectLabel'));

        System.assertEquals(true, String.isNotEmpty(objectLabel));
    }

    @isTest static void test_getData() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test", "searchMode": "SOQL"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        List<Object> data = (List<Object>) results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>) data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getDataSOSL() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test", "searchMode": "SOSL"}';

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{a.Id});
        String responseString = LookupCtrl.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        List<Object> data = (List<Object>) results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>) data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_subtitleField() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        String jsonString = '{"searchField":"Name", "subtitleField": "Name", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test", "searchMode": "SOQL"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        List<Object> data = (List<Object>) results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>) data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_addressField() {
        Account a = new Account(
            Name = 'Test Account',
            BillingStreet = 'Test Street',
            BillingCity = 'Test City',
            BillingState = 'Test State',
            BillingCountry = 'Test Country',
            BillingPostalCode = 'Test Postal Code');
        insert a;

        String jsonString = '{"searchField":"Name", "subtitleField": "BillingAddress", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test","searchMode": "SOQL"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        List<Object> data = (List<Object>) results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>) data.get(0);

        System.assertEquals(a.Id, record.get('value'));
    }

    @isTest static void test_getData_reference() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        Contact c = new Contact(
            LastName = 'Contact',
            FirstName = 'Test',
            AccountId = a.Id);
        insert c;

        String jsonString = '{"searchField":"FirstName", "subtitleField": "Account.Name", "object": "Contact", "filter": "Name = \'Test Contact\'", "searchTerm": "Test", "searchMode": "SOQL"}';

        Test.startTest();
        String responseString = LookupCtrl.getRecords(jsonString);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseString);
        Map<string, Object> results = (Map<String, Object>) response.get('results');
        List<Object> data = (List<Object>) results.get('data');

        System.assertEquals(1, data.size());

        Map<String, Object> record = (Map<String, Object>) data.get(0);

        System.assertEquals(c.Id, record.get('value'));
    }
}
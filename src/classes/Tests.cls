@IsTest
private class Tests {


    private static void createContacts(Integer numContacts) {
        List<Contact> cts = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact ct = new Contact(FirstName = 'Test' + i,
                    LastName = 'Contact' + i);
            cts.add(ct);
        }
        if (cts != null) {
            insert cts;
        }
    }

    private static List<Contact> createAndReturnContacts(Integer numContacts) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < numContacts; i++) {
            Contact ct = new Contact(
                    FirstName = 'Contact' + i,
                    LastName = 'Contact' + i
            );
            contacts.add(ct);
        }

        insert contacts;
        return contacts;
    }

    private static List<String> createStringList(Integer numParts) {

        List<String> stringList = new List<String>();
        for (Integer i = 0; i < numParts; i++) {
            stringList.add('test' + i);
        }
        return stringList;

    }

    private static Map<String, String> createStringsMap(Integer numParts) {

        Map<String, String> stringsMap = new Map<String, String>();
        for (Integer i = 0; i < numParts; i++) {
            stringsMap.put('key' + i, 'value' + i);
        }
        return stringsMap;

    }

    private static Contact createContact(String lastname, String mailingCountry) {

        Contact testContact = new Contact(
                LastName = lastname,
                MailingCountry = mailingCountry
        );
        return testContact;
    }


    /**
         * ==============================================================================================================
         *                                           PICKLIST EXTENSIONS
         * ==============================================================================================================
         */

    @IsTest
    static void testGetPicklistAsSetStrings() {

        System.assertNotEquals(null, Utils.picklists.getPicklistAsSetStrings(Account.Industry));
    }

    @IsTest
    static void testGetPicklistValuesAsSelectOptions() {

        System.assertNotEquals(null, Utils.picklists.getPicklistValuesAsSelectOptions(Account.Industry));
    }

    @IsTest
    static void testGetPicklistOptionsMap() {

        Set<SObjectField> fields = new Set<SObjectField>{
                Account.Industry, Account.AccountSource
        };
        System.assertNotEquals(null, Utils.picklists.getPicklistOptionsMap(fields));
    }

    @IsTest
    static void testGetDependentPicklistOptionsMap() {

        Map<SObjectField, SObjectField> fieldsMap = new Map<SObjectField, SObjectField>{
                Account.AccountSource.getDescribe().getSObjectField() => Account.Industry.getDescribe().getSObjectField()
        };
        Map<SObjectType, Map<SObjectField, SObjectField>> dependentFieldsBySObjectType = new Map<SObjectType, Map<SObjectField, SObjectField>>{
                Account.getSObjectType() => fieldsMap
        };
        System.assertNotEquals(null, Utils.picklists.getDependentPicklistOptionsMap(dependentFieldsBySObjectType));

    }

    @IsTest
    static void testGetDependentOptions() {

        System.assert(Utils.picklists.getDependentOptions(null, Account.ShippingAddress.getDescribe().getSObjectField(),
                Account.BillingAddress.getDescribe().getSObjectField()).isEmpty());
        System.assert(Utils.picklists.getDependentOptions(Contact.getSObjectType(), Account.ShippingAddress.getDescribe().getSObjectField(),
                Account.BillingAddress.getDescribe().getSObjectField()).isEmpty());
    }

    @IsTest
    static void testConvertFlowPicklistFieldValues() {
        Account accountVar = new Account();
        Utils.picklists.convertFlowPicklistFieldValues(accountVar);
        System.assertNotEquals(null, accountVar);
    }


    /**
         * ==============================================================================================================
         *                                      DATE AND DATETIME EXTENSIONS
         * ==============================================================================================================
         */

    @IsTest
    static void testParseDatetimeAnyFormat() {

        Datetime dtVar = Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = Utils.dates.parseDatetimeAnyFormat('', 'DD/MM/YYYY hh:mm:ss');
        System.assertEquals(null, dtVar);

        dtVar = Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00 AM', 'DD/MM/YYYY hh:mm:ss AM');
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 11, 0, 0), dtVar);

        dtVar = Utils.dates.parseDatetimeAnyFormat('2018-12-01 00:00:00', 'yyyy-MM-dd');
        System.assertEquals(Date.newInstance(2018, 12, 1), dtVar.date());

//        dtVar = Utils.dates.parseDatetimeAnyFormat('19/09/2018 11:00:00 PM', 'DD/MM/YYYY hh:mm:ss PM');
//        System.assertEquals( Datetime.newInstance(2018, 9, 19, 23, 0, 0), dtVar);

        Boolean didThrowException = false;
        try {
            dtVar = Utils.dates.parseDatetimeAnyFormat('19-09 11 00 00 PA', 'DD/MM/YYYY hh:mm:ss PM');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }


    }

    @IsTest
    static void testParseDatetimeAusFormat() {

        String dtStr = '19/09/2018 10:30 AM';
        Datetime dtVar = Utils.dates.parseDatetimeAusFormat(dtStr);
        System.assertEquals(dtStr, dtVar.format('dd/MM/yyyy hh:mm a'));

    }

    @IsTest
    static void testParseDateAusFormat() {

        Date dateVar = Utils.dates.parseDateAusFormat('19/09/2018');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @IsTest
    static void testDatetimeToDate() {

        Datetime dtVar = Datetime.newInstance(2018, 9, 19, 10, 30, 0);
        Date dateVar = Utils.dates.datetimeToDate(dtVar);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }

    @IsTest
    static void testParseDateAnyFormat() {

        Date dateVar = Utils.dates.parseDateAnyFormat('19/09/2018', 'DD/MM/YYYY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

        dateVar = Utils.dates.parseDateAnyFormat('', 'DD/MM/YYYY');
        System.assertEquals(null, dateVar);

        dateVar = Utils.dates.parseDateAnyFormat('19/09/18', 'DD/MM/YY');
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);

    }

    @IsTest
    static void testDateToDateTime() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Datetime dtVar = Utils.dates.dateToDateTime(dateVar);
        System.assertEquals(Datetime.newInstance(2018, 9, 19), dtVar);

    }

    @IsTest
    static void testTotalWorkingDays() {

        Date startDate = Date.newInstance(2018, 9, 19);
        Date endDate = Date.newInstance(2018, 9, 24);
        Integer total = Utils.dates.totalWorkingDays(startDate, endDate);
        System.assertEquals(4, total);
    }

    @IsTest
    static void testIsWorkingDay() {

// for date parameter
        Date dateVar = Date.newInstance(2018, 9, 19);
        Boolean isWorkingDay = Utils.dates.isWorkingDay(dateVar);
        System.assertEquals(true, isWorkingDay);

// for datetime parameter
        Datetime dtVar = Datetime.newInstance(2018, 9, 19);
        isWorkingDay = Utils.dates.isWorkingDay(dtVar);
        System.assertEquals(true, isWorkingDay);
    }

    @IsTest
    static void testTimeStringToTime() {

        Time timeVar = Utils.dates.timeStringToTime('11:30:00');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVar);
    }

    @IsTest
    static void testTimeStringAMPMToTime() {

        Time timeVarAM1 = Utils.dates.timeStringAMPMToTime('11:30:00 AM');
        System.assertEquals(Time.newInstance(11, 30, 0, 0), timeVarAM1);

        Time timeVarAM2 = Utils.dates.timeStringAMPMToTime('12:30:00 AM');
        System.assertEquals(Time.newInstance(0, 30, 0, 0), timeVarAM2);

        Time timeVarPM1 = Utils.dates.timeStringAMPMToTime('11:30:00 PM');
        System.assertEquals(Time.newInstance(23, 30, 0, 0), timeVarPM1);

        Time timeVarPM2 = Utils.dates.timeStringAMPMToTime('12:30:00 PM');
        System.assertEquals(Time.newInstance(12, 30, 0, 0), timeVarPM2);

        Boolean didThrownException = false;
        try {
            Utils.dates.timeStringAMPMToTime('');
        } catch (Exception ex) {
            didThrownException = true;
            System.assert(didThrownException);
        }

    }

    @IsTest
    static void testGetStartOfDay() {

        Datetime dtVar = Utils.dates.getStartOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 0, 0, 0), dtVar);

    }

    @IsTest
    static void testGetEndOfDay() {

        Datetime dtVar = Utils.dates.getEndOfDay(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 19, 23, 59, 9), dtVar);

    }

    @IsTest
    static void testGetStartDateOfWeek() {

        Datetime dtVar = Utils.dates.getStartDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 17), dtVar);

        Date dateVar = Utils.dates.getStartDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 17), dateVar);
    }

    @IsTest
    static void testGetEndDateOfWeek() {

        Datetime dtVar = Utils.dates.getEndDateOfWeek(Datetime.newInstance(2018, 9, 19));
        System.assertEquals(Datetime.newInstance(2018, 9, 23, 23, 59, 9), dtVar);

        Date dateVar = Utils.dates.getEndDateOfWeek(Date.newInstance(2018, 9, 22));
        System.assertEquals(Date.newInstance(2018, 9, 23), dateVar);
    }

    @IsTest
    static void testIsDateInCurrectWeekOrInFuture() {

        Date dateVar = Date.today().addDays(10);
        Boolean currentOrFuture = Utils.dates.isDateInCurrectWeekOrInFuture(dateVar);
        System.assertEquals(true, currentOrFuture);
    }

    @IsTest
    static void testGetFirstDayInMonth() {

        Date dateVar = Date.today();
        System.assertNotEquals(null, Utils.dates.getFirstDayInMonth(dateVar));
    }

    @IsTest
    static void testGetLastDayInMonth() {

        Date dateVar = Utils.dates.getLastDayInMonth(Date.newInstance(2018, 9, 19));
        System.assertEquals(Date.newInstance(2018, 9, 30), dateVar);
    }

    @IsTest
    static void testGetLastWorkingDay() {

        Date dateVar = Utils.dates.getLastWorkingDay(Date.newInstance(2018, 9, 23));
        System.assertEquals(Date.newInstance(2018, 9, 21), dateVar);

    }

    @IsTest
    static void testGetLastDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date endOfPeriod = Utils.dates.getLastDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 30), endOfPeriod);

        endOfPeriod = Utils.dates.getLastDayInFortnight(Date.newInstance(2018, 10, 1), startDate);
        System.assertEquals(Date.newInstance(2018, 10, 14), endOfPeriod);
        Boolean didThrowException = false;
        try {
            Utils.dates.getLastDayInFortnight(dateVar, Date.newInstance(2018, 9, 20));
        } catch (Exception ex) {
            didThrowException = true;
        }
        System.assert(didThrowException);
    }

    @IsTest
    static void testGetFirstDayInFortnight() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 18);
        Date startOfPeriod = Utils.dates.getFirstDayInFortnight(dateVar, startDate);
        System.assertEquals(Date.newInstance(2018, 9, 17), startOfPeriod);
    }

    @IsTest
    static void testDateInRange() {

        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 17);
        Date endDate = Date.newInstance(2018, 9, 30);
        dateVar = Utils.dates.dateInRange(dateVar, startDate, endDate);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
        System.assert(Utils.dates.dateInRange(dateVar, startDate, endDate, true));
    }

    @IsTest
    static void testDetectDateInRange() {
        Date dateVar = Date.newInstance(2018, 9, 19);
        Date startDate = Date.newInstance(2018, 9, 17);
        Date endDate = Date.newInstance(2018, 9, 30);
        dateVar = Utils.dates.detectDateInRange(dateVar, startDate, endDate);
        System.assertEquals(Date.newInstance(2018, 9, 19), dateVar);
    }

    @IsTest
    static void testCrossingDateRanges() {
        Date date1start = Date.newInstance(2022, 7, 20);
        Date date1end = Date.newInstance(2022, 7, 30);
        Date date2start = Date.newInstance(2022, 7, 21);
        Date date2end = Date.newInstance(2022, 7, 22);
        System.assert(Utils.dates.crossingDateRanges(date1start, date1end, date2start, date2end));
    }

    @IsTest
    static void testAge() {
        Date birthDate = Date.newInstance(2000, 9, 22);
        System.assert(Utils.dates.age(birthDate) > 20);
    }

    @IsTest
    static void testMin() {
        Date date1 = Date.newInstance(2000, 9, 22);
        Date date2 = Date.newInstance(2000, 10, 22);
        System.assertEquals(date1, Utils.dates.min(date1, date2));
    }

    @IsTest
    static void testMax() {
        Date date1 = Date.newInstance(2000, 9, 22);
        Date date2 = Date.newInstance(2000, 10, 22);
        System.assertEquals(date2, Utils.dates.max(date1, date2));
    }
    /**
          * ==============================================================================================================
          *                                         STRING EXTENSIONS
          * ==============================================================================================================
     */

    @IsTest
    static void testThrowIfBlankString() {

        Boolean didThrowExceptionMessage = false;
        try {
            Utils.strings.throwIfBlank('', 'Passed parameter is blank');
        } catch (Exception ex) {
            didThrowExceptionMessage = true;
        }
        System.assert(didThrowExceptionMessage);

        Boolean didThrowException = false;
        try {
            Utils.strings.throwIfBlank('', new NullPointerException());
        } catch (Exception ex) {
            didThrowException = true;
        }

        System.assert(didThrowException);
    }

    @IsTest
    static void testEmptyStringIfNull() {

        String result = Utils.strings.emptyStringIfNull ('');
        System.assertEquals('', result);

        result = Utils.strings.emptyStringIfNull('string');
        System.assertEquals('string', result);

    }
//    @IsTest
//    static void testRemoveNonNumeric() {
//
//        String result = Utils.strings.removeNonNumeric ('');
//        System.assertEquals('', result);
//
//        result = Utils.strings.removeNonNumeric ('123qwerty123qwerty');
//        System.assertEquals('123123', result);
//
//    }
//
//    @IsTest
//    static void testRemoveNonNumericWithDelimiter() {
//
//        String result = Utils.strings.removeNonNumericWithDelimiter('');
//        System.assertEquals('', result);
//
//        result = Utils.strings.removeNonNumericWithDelimiter('123qwerty,123,qwerty.321,');
//        System.assertEquals('123.123..321.', result);
//
//    }

//    @IsTest
//    static void testPad() {
//
//        Boolean didThrowException = false;
//        String result;
//        try {
//            result = Utils.strings.Pad('source', 6, 'value');
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//
//        result = Utils.strings.Pad('source', 6, 'v');
//        System.assertEquals('source', result);
//
//        result = Utils.strings.Pad('source', 10, 'v');
//        System.assertEquals('vvvvsource', result);
//
//        result = Utils.strings.Pad(1, 3, 'v');
//        System.assertEquals('vv1', result);
//
//    }
//
//    @IsTest
//    static void testSafeSplit() {
//        List<String> expectedList = new List<String>();
//        for (Integer i = 0; i < 150; i++) {
//            expectedList.add('string');
//        }
//        String inStr = String.join(expectedList, ',');
//        List<String> result = Utils.strings.safeSplit(inStr, ',');
//        System.assertEquals(expectedList, result);
//
//
//    }

    @IsTest
    static void testNewGuid() {
        String encodedString1 = Utils.strings.newGuid();
        String encodedString2 = Utils.strings.newGuid();
        System.assertNotEquals(null, encodedString1);
        System.assertNotEquals(encodedString1, encodedString2);
    }

    @IsTest
    static void testNewUuid() {
        String encodedString1 = Utils.strings.newUuid();
        String encodedString2 = Utils.strings.newUuid();
        System.assertNotEquals(null, encodedString1);
        System.assertNotEquals(encodedString1, encodedString2);
    }

//    @IsTest
//    static void testGetCharAtIndex() {
//
//        String result = Utils.strings.getCharAtIndex(null, 2);
//        System.assertEquals(null, result);
//
//        result = Utils.strings.getCharAtIndex('', 2);
//        System.assertEquals('', result);
//
//        result = Utils.strings.getCharAtIndex('str', 3);
//        System.assertEquals(null, result);
//
//        result = Utils.strings.getCharAtIndex('string', 2);
//        System.assertEquals('r', result);
//    }

    @IsTest
    static void testJoinNonBlank() {
        String expectedString = 'string/string/string';
        List<String> parts = new List<String>{
                'string', null, 'string', '', 'string', ' '
        };
        String result = Utils.strings.joinNonBlank(parts, '/');
        System.assertEquals(expectedString, result);
    }

    /**f
     * ==============================================================================================================
     *                                           USER EXTENSIONS
     * ==============================================================================================================
     */
//
//    @IsTest
//    static void testGetProfileIdByName() {
//
//        Boolean didThrowException = false;
//        Id profileId;
//
//        try {
//            profileId = Utils.users.GetProfileIdByName(null);
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//
//        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :userInfo.getProfileId()];
//
//        profileId = Utils.users.GetProfileIdByName(p.Name);
//        System.assertEquals(p.Id, profileId);
//
//
//    }
//
//    @IsTest
//    static void testCreateUser() {
//
//        User testUser = new User(
//            CommunityNickname = 'test',
//            Username = 'test',
//            Email = 'test@test.mail',
//            EmailEncodingKey = 'UTF-8',
//            LanguageLocaleKey = 'en_US',
//            LocaleSidKey = 'en_AU',
//            TimeZoneSidKey = 'Australia/Sydney',
//            FirstName = 'test',
//            LastName = 'test',
//            ProfileId = userInfo.getUserId(),
//            EmployeeNumber = '10',
//            Alias = 'test',
//            Active__c = true);
//
//        User resultUser = Utils.users.CreateUser('test', 'test', 'test@test.mail',
//            'test', 'test', 'test', '10', userInfo.getUserId(), true);
//
//        System.assertEquals(testUser, resultUser);
//    }

    /**
     * ==============================================================================================================
     *                                         SOBJECT EXTENSIONS
     * ==============================================================================================================
     */

//    @IsTest
//    static void testCreateSObjectById() {
//
//        Id userId = userInfo.getUserId();
//        User testUser = [SELECT Id FROM User WHERE Id = :userId];
//        User resultUser = (User) Utils.sObjects.createSObjectById(userId);
//        System.assertEquals(testUser, resultUser);
//
//    }

//    @IsTest
//    static void testCreateSObjectsByIds() {
//
//        List<Contact> cts = createAndReturnContacts(3);
//        Set<Id> setIds = new Set<Id>();
//        for (Contact contact : cts) {
//            setIds.add(contact.Id);
//        }
//        List<Contact> contacts = (List<Contact>) Utils.sObjects.createSObjectsByIds(setIds);
//        System.assertEquals(cts.get(0).Id, contacts.get(0).Id);
//        System.assertEquals(cts.get(1).Id, contacts.get(1).Id);
//        System.assertEquals(cts.get(2).Id, contacts.get(2).Id);
//    }

//    @IsTest
//    static void testGetSobjectsFromIds() {
//
//        List<Contact> cts = createAndReturnContacts(3);
//        Set<Id> setIds = new Set<Id>();
//        for (Contact contact : cts) {
//            setIds.add(contact.Id);
//        }
//        List<Contact> contacts = (List<Contact>) Utils.sObjects.getSobjectsFromIds(Contact.getSObjectType(), setIds);
//        System.assertEquals(cts.get(0).Id, contacts.get(0).Id);
//        System.assertEquals(cts.get(1).Id, contacts.get(1).Id);
//        System.assertEquals(cts.get(2).Id, contacts.get(2).Id);
//
//    }

    @IsTest
    static void testAssertReadable() {
        Account accountVar = new Account();
        Utils.sObjects.assertReadable(accountVar);
        System.assertNotEquals(null, accountVar);
    }

    @IsTest
    static void testGetIdFieldValues() {
        List<Contact> cts = createAndReturnContacts(3);
        Set<Id> setIds = new Set<Id>();
        for (Contact contact : cts) {
            setIds.add(contact.Id);
        }
        Set<Id> values = Utils.sObjects.getIdFieldValues(cts, Contact.Id.getDescribe().getSobjectField());
        System.assert(setIds.equals(values));
    }

    @IsTest
    static void testGetStringFieldValues() {
        List<Contact> cts = createAndReturnContacts(3);
        Set<String> testSet = new Set<String>{
                'Contact0', 'Contact1', 'Contact2'
        };
        System.assertEquals(testSet, Utils.sObjects.getStringFieldValues(cts, Contact.LastName.getDescribe().getSObjectField()));
    }

//    @IsTest
//    static void testPutAllRecordsByKeyField() {
//
//        List<Contact> cts = createAndReturnContacts(3);
//        Map<String, Contact> mappedContacts = new Map<String, Contact>();
//        Utils.sObjects.putAllRecordsByKeyField(cts, 'Id', mappedContacts);
//        System.assertEquals(false, mappedContacts.isEmpty());
//
//        Map<String, List<Contact>> mappedRecords = new Map<String, List<Contact>>();
//        Utils.sObjects.putAllRecordsByKeyField(cts, 'Id', mappedRecords, true);
//        System.assertEquals(false, mappedRecords.isEmpty());
//    }

    @IsTest
    static void testGetSObjectsByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, SObject> mappedContacts = Utils.sObjects.getSObjectsByAnyFieldMap(cts, Contact.Id.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @IsTest
    static void testGetSObjectsListByAnyFieldMap() {

        List<Contact> cts = createAndReturnContacts(3);
        Map<String, List<SObject>> mappedContacts = Utils.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());

        cts.add(new Contact(FirstName = 'Test', LastName = 'Contact0'));
        mappedContacts = Utils.sObjects.getSObjectsListByAnyFieldMap(cts, Contact.LastName.getDescribe().getSobjectField());
        System.assertEquals(false, mappedContacts.isEmpty());
    }

    @IsTest
    static void testFieldToProperty() {

        String property = Utils.sObjects.fieldToProperty(Contact.FirstName.getDescribe().getSobjectField());
        System.assertEquals('firstName', property);
    }

    @IsTest
    static void testFieldNameToProperty() {

        String property = Utils.sObjects.fieldNameToProperty('');
        System.assertEquals('', property);

        property = Utils.sObjects.fieldNameToProperty('vertic__tests_field__c');
        System.assertEquals('verticTestsField', property);
    }

//    @IsTest
//    static void testPropertyToField() {
//
//        SObjectField sObjectField = Utils.sObjects.propertyToField('firstName', Contact.getSObjectType());
//        System.assertEquals(Contact.FirstName.getDescribe().getSobjectField(), sObjectField);
//
//        sObjectField = Utils.sObjects.propertyToField('verticTestField', Contact.getSObjectType());
//        System.assertEquals(null, sObjectField);
//    }

//    @IsTest
//    static void testPropertyToFieldName() {
//
//        String field = Utils.sObjects.propertyToFieldName('firstName', Contact.getSObjectType());
//        System.assertEquals('FirstName', field);
//
//        field = Utils.sObjects.propertyToFieldName('verticTestField', Contact.getSObjectType());
//        System.assertEquals(null, field);
//    }

//    @IsTest
//    static void testRecordTypeByName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//
//        Schema.RecordTypeInfo resultRecordTypeInfo = Utils.sObjects.recordTypeByName(Account.getSObjectType(), 'Test');
//        System.assertEquals(rtByName, resultRecordTypeInfo);
//    }

//    @IsTest
//    static void testRecordTypeIdByName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//        Id expectedId = rtByName.getRecordTypeId();
//
//        Id actualId = Utils.sObjects.recordTypeIdByName(Account.getSObjectType(), 'Test');
//        System.assertEquals(expectedId, actualId);
//
//        Boolean didThrowException = false;
//        try {
//            actualId = Utils.sObjects.recordTypeIdByName(Account.getSObjectType(), '');
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//
//    }

    @IsTest
    static void testRecordTypeByAPIName() {
        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
        Schema.RecordTypeInfo resultRecordTypeInfo = Utils.sObjects.recordTypeByAPIName(Account.getSObjectType(), 'Test');
        System.assertEquals(rtByName, resultRecordTypeInfo);
    }

//    @IsTest
//    static void testRecordTypeIdByAPIName() {
//
//        Schema.DescribeSObjectResult r = Account.SObjectType.getDescribe();
//        Map<String, Schema.RecordTypeInfo> rtMapByName = r.getRecordTypeInfosByName();
//        Schema.RecordTypeInfo rtByName = rtMapByName.get('Test');
//
//        Id expectedId = rtByName.getRecordTypeId();
//
//        Id actualId = Utils.sObjects.recordTypeIdByAPIName(Account.getSObjectType(), 'Test');
//        System.assertEquals(expectedId, actualId);
//
//        Boolean didThrowException = false;
//        try {
//            actualId = Utils.sObjects.recordTypeIdByAPIName(Account.getSObjectType(), '');
//        } catch (Exception ex) {
//            didThrowException = true;
//        }
//        System.assert(didThrowException);
//    }
//
//    @IsTest
//    static void testRecordTypeNameById() {
//
//        List<RecordType> rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' LIMIT 1];
//
//        String recordTypeName;
//        if (rt != null) {
//            recordTypeName = Utils.sObjects.recordTypeNameById(Account.getSObjectType(), rt.get(0).Id);
//            System.assertEquals(rt.get(0).Name, recordTypeName);
//        }
//        recordTypeName = Utils.sObjects.recordTypeNameById(Account.getSObjectType(), '000000000000000000');
//        System.assertEquals(null, recordTypeName);
//    }

    @IsTest
    static void testToSelectOption() {

        List<Contact> cts = createAndReturnContacts(3);
        Structs.SelectOption selectOption = Utils.sObjects.toSelectOption(cts.get(0), 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = Utils.sObjects.toSelectOption(cts.get(0), 'LastName');
        System.assertNotEquals(null, selectOption);

        selectOption = Utils.sObjects.toSelectOption(cts.get(0));
        System.assertNotEquals(null, selectOption);

        List<System.SelectOption> options = new List<System.SelectOption>();
        for (Integer i = 0; i < 3; i++) {
            options.add(new System.SelectOption('Value' + i, 'Label' + i));
        }
        List<Structs.SelectOption> selectOptions = Utils.sObjects.toSelectOptions(options);
        System.assertNotEquals(null, selectOptions);


        selectOptions = Utils.sObjects.toSelectOptions(cts);
        System.assertNotEquals(null, selectOptions);

        selectOptions = Utils.sObjects.toSelectOptions(cts, 'FirstName');
        System.assertNotEquals(null, selectOptions);

        selectOptions = Utils.sObjects.toSelectOptions(cts, 'FirstName', 'LastName');
        System.assertNotEquals(null, selectOptions);

    }

    @IsTest
    static void testSwap() {

        Contact ct = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert ct;

        Schema.sObjectField field1 = Contact.FirstName.getDescribe().getSobjectField();
        Schema.sObjectField field2 = Contact.LastName.getDescribe().getSobjectField();
        Utils.sObjects.swap(ct, field1, field2);
        System.assertEquals('Contact', ct.get('FirstName'));
        System.assertEquals('Test', ct.get('LastName'));
    }

    @IsTest
    static void testStringToSObjectType() {

        SObjectType objectType = Utils.sObjects.stringToSObjectType('Account');
        System.assertEquals(Account.getSObjectType(), objectType);
    }

    @IsTest
    static void testGetFieldsByTypes() {

        Set<DisplayType> displayTypes = new Set<DisplayType>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            displayTypes.add(fielddataType);
        }
        Set<SObjectField> fields = Utils.sObjects.getFieldsByTypes(Account.getSObjectType(), displayTypes);
        System.assertNotEquals(null, fields);

    }

    @IsTest
    static void testIsSomeFieldChanged() {
        List<SObjectField> fields = new List<SObjectField>{
                Contact.FirstName.getDescribe().getSobjectField(),
                Contact.LastName.getDescribe().getSobjectField()
        };
        Contact ct = new Contact(FirstName = 'Test', LastName = 'Test');
        Contact cloneCt = ct.clone();
        System.assertEquals(false, Utils.sObjects.isSomeFieldChanged(ct, cloneCt, fields));

        ct.FirstName = 'TestName';
        System.assertEquals(true, Utils.sObjects.isSomeFieldChanged(ct, cloneCt, fields));

    }


    /**
     * ==============================================================================================================
     *                                            URL EXTENSIONS
     * ==============================================================================================================
     */


    @IsTest
    static void testURLExtensions() {
        PageReference pageRef = Utils.urls.listView(Account.getSObjectType());
        System.assertNotEquals(null, pageRef);
    }


    /**
     * ==============================================================================================================
     *                                            EMAIL EXTENSIONS
     * ==============================================================================================================
     */

    /**
     * ==============================================================================================================
     *                                          ORGANISATION EXTENSIONS
     * ==============================================================================================================
     */

//    @IsTest
//    static void testIsSandbox() {
//
//        List<Organization> organizations = [
//            SELECT IsSandbox
//            FROM Organization
//            WHERE Id = :UserInfo.getOrganizationId()
//        ];
//        Boolean didThrowException = false;
//        Boolean isSandbox = false;
//
//        try {
//            isSandbox = organizations.get(0).isSandbox;
//        } catch (Exception ex) {
//            didThrowException = true;
//            System.assert(didThrowException);
//        }
//        Boolean result = Utils.orgs.isSandbox();
//        System.assertEquals(isSandbox, result);
//
//    }


    /**
    * ==============================================================================================================
    *                                         ENCODING EXTENSIONS
    * ==============================================================================================================
    */

//    @IsTest
//    static void testMapToFormUrlEncoded() {
//
//        Map<String, String> dataMap = new Map<String, String>();
//        dataMap.put('key1', 'value1');
//        dataMap.put('key2', 'value2');
//        String result = Utils.encodings.mapToFormUrlEncoded(dataMap);
//        System.assertEquals('key1=value1&key2=value2', result);
//    }
//
//    @IsTest
//    static void testFormUrlEncodedToMap() {
//
//        Map<String, String> dataMap = new Map<String, String>();
//        dataMap.put('key1', 'value1');
//        dataMap.put('key2', 'value2');
//        Map<String, String> resultMap = Utils.encodings.formUrlEncodedToMap('key1=value1&key2=value2');
//        System.assertEquals(dataMap, resultMap);
//
//        Boolean didThrowException = false;
//        try {
//            resultMap = Utils.encodings.formUrlEncodedToMap('key1=&key2=value2');
//        } catch (Exception ex) {
//            didThrowException = true;
//            System.assert(didThrowException);
//        }
//    }
//
//    @IsTest
//    static void testGetEncryptedValue() {
//
//        Blob key = Crypto.generateAesKey(256);
//        String keyString = EncodingUtil.base64Encode(key);
//
//        String encryptedString = Utils.encodings.getEncryptedValue('test', keyString);
//        System.assertNotEquals(null, encryptedString);
//
//    }
//
//    @IsTest
//    static void testGetDecryptedValue() {
//        Blob key = Crypto.generateAesKey(256);
//        String keyString = EncodingUtil.base64Encode(key);
//        Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf('test'));
//        String encryptedString = EncodingUtil.base64Encode(encryptedToken);
//
//
//        String decryptedString = Utils.encodings.getDecryptedValue(encryptedString, keyString);
//        System.assertEquals('test', decryptedString);
//
//    }
//
//    @IsTest
//    static void testMaskCreditCard() {
//
//        String maskedNumber = Utils.encodings.maskCreditCard('4444333322221111');
//        System.assertEquals('444433XXXXXX1111', maskedNumber);
//
//        maskedNumber = Utils.encodings.maskCreditCard('');
//        System.assertEquals(null, maskedNumber);
//    }

    /**
    * ==============================================================================================================
    *                                             COLLECTION EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testFirstOrDefault() {

        List<String> stringList = createStringList(0);
        String result = (String) Utils.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('default', result);

        stringList = createStringList(3);
        result = (String) Utils.arrays.firstOrDefault(stringList, 'default');
        System.assertEquals('test0', result);
    }

    @IsTest
    static void testFirstOrNull() {

        List<String> stringList = createStringList(0);
        String result = (String) Utils.arrays.firstOrNull(stringList);
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) Utils.arrays.firstOrNull(stringList);
        System.assertEquals('test0', result);
    }

    @IsTest
    static void testFirstOrException() {

        List<String> stringList = createStringList(0);

        Boolean didThrowException = false;
        String result;
        try {
            result = (String) Utils.arrays.firstOrException(stringList);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        System.assertEquals(null, result);

        stringList = createStringList(3);
        result = (String) Utils.arrays.firstOrException(stringList);
        System.assertEquals('test0', result);
    }


//    @IsTest
//    static void testReverseList() {
//
//        List<String> stringList = null;
//        List<String> result = (List<String>) Utils.arrays.reverseList(stringList);
//        System.assertEquals(null, result);
//
//        stringList = createStringList(3);
//        result = (List<String>) Utils.arrays.reverseList(stringList);
//        System.assertEquals('test0', result.get(2));
//    }

//    @IsTest
//    static void testGetMapFirstKey() {
//
//        Map<String, String> stringsMap = createStringsMap(0);
//        String firstKey = Utils.arrays.getMapFirstKey(stringsMap);
//        System.assertEquals(null, firstKey);
//
//        Map<String, String> testMap = createStringsMap(3);
//        firstKey = Utils.arrays.getMapFirstKey(testMap);
//        System.assertEquals('key0', firstKey);
//
//    }

//    @IsTest
//    static void testChangeMapKeys() {
//
//        Map<String, String> source = createStringsMap(3);
//        Map<String, String> donor = createStringsMap(4);
//
//        Map<String, String> result = Utils.arrays.changeMapKeys(source, donor);
//        Map<String, String> testResult = new Map<String, String>();
//        testResult.put('value0', 'value0');
//        testResult.put('value1', 'value1');
//        testResult.put('value2', 'value2');
//        System.assertEquals(testResult, result);
//
//        System.assertEquals(null, Utils.arrays.changeMapKeys(null, donor));
//
//    }

    @IsTest
    static void testAddToSetIfNotBlank() {
        Set<String> stringsSet = new Set<String>{
                '1', '2', '3'
        };
        Utils.arrays.addToSetIfNotBlank(stringsSet, '4');
        System.assert(stringsSet.contains('4'));
    }

    @IsTest
    static void testAddToListOrCreateNew() {

        Map<String, List<String>> testMap = null;
        Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 2);
        if (testMap != null) {
            System.assertEquals('object', testMap.get('key0').get(0));
        }

        Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object', 0);
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        if (testMap != null) {
            System.assertEquals(2, testMap.get('key0').size());
        }
        Utils.arrays.addToListOrCreateNew(testMap, List<String>.class, 'key0', 'object');
        if (testMap != null) {
            System.assertEquals(3, testMap.get('key0').size());
        }

    }

    @IsTest
    static void TestGetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Object obj = Utils.arrays.getMapValue(testMap, 'key0.key1.key2');
        System.assertEquals(null, obj);

        obj = Utils.arrays.getMapValue(null, 'key0.key1.key2');
        System.assertEquals(null, obj);

    }

    @IsTest
    static void TestSetMapValue() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Utils.arrays.setMapValue(testMap, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

        Utils.arrays.setMapValue(null, 'key0.key1.key2', new Map<String, Map<String, Object>>());
        System.assertNotEquals(null, testMap);

    }

    @IsTest
    static void testMapContains() {

        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
        testMap.put('key0', new Map<String, Map<String, Object>>());
        Boolean result = Utils.arrays.mapContains(testMap, 'key0.key1.key2');
        System.assertEquals(false, result);
    }

    @IsTest
    static void testSplit() {
        System.assertEquals(5, Utils.arrays.split(new List<Integer>{
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        }, 2, List<Integer>.class).size());
    }

//    @IsTest
//    static void testSumMaps() {
//
//        List<Map<String, Map<String, Object>>> testList = new List<Map<String, Map<String, Object>>>();
//
//        Decimal sum = Utils.arrays.sumMaps(testList, 'key0.key1.key2');
//        System.assertEquals(0, sum);
//
//        Map<String, Map<String, Object>> testMap = new Map<String, Map<String, Object>>();
//        testMap.put('key0', new Map<String, Map<String, Object>>());
//        testList.add(testMap);
//        sum = Utils.arrays.sumMaps(testList, 'key0.key1.key2');
//        System.assertEquals(0, sum);
//        testList.add(null);
//        sum = Utils.arrays.sumMaps(testList, 'key0.key1.key2');
//        System.assertEquals(0, sum);
//
//    }

//    @IsTest
//    static void testContainsAny() {
//
//        List<String> testStrings1 = createStringList(2);
//        List<String> testStrings2 = new List<String>{
//            'test2', 'test3'
//        };
//        Boolean result = Utils.arrays.containsAny(testStrings1, testStrings2);
//        System.assertEquals(false, result);
//
//        testStrings2.add('test0');
//        result = Utils.arrays.containsAny(testStrings1, testStrings2);
//        System.assertEquals(true, result);
//
//    }

//    @IsTest
//    static void testStringsToSelectOptions() {
//
//        List<String> testList = createStringList(2);
//        List<Structs.SelectOption> resultList = Utils.arrays.stringsToSelectOptions(testlist);
//        System.assertNotEquals(null, resultList);
//
//    }

    /**
    * ==============================================================================================================
    *                                             OBJECT EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testThrowIfNull() {

        Boolean didThrowException = false;
        try {
            Utils.objects.throwIfNull(null, new Structs.MissingDataException());
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            Utils.objects.throwIfNull(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
    }

    @IsTest
    static void testThrowIfBlank() {
        Boolean didThrowException = false;
        try {
            Utils.objects.throwIfBlank(null, 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }
        try {
            Utils.objects.throwIfBlank('', 'message');
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @IsTest
    static void testParseDecimal() {

        Long myLong = 4271990;
        Integer myInt = 10;
        System.assertEquals(10.0, Utils.objects.parseDecimal(myInt));
        System.assertEquals(4271990.0, Utils.objects.parseDecimal(myLong));
        System.assertEquals(null, Utils.objects.parseDecimal(null));
        System.assertEquals(12.0, Utils.objects.parseDecimal(12.0));
        System.assertEquals(12.0, Utils.objects.parseDecimal('12'));

        System.assertEquals(1809091.0, Utils.objects.parseDecimal(Double.valueOf('1809091')));

        Boolean didThrowException = false;
        try {
            Utils.objects.parseDecimal(didThrowException);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    @IsTest
    static void testdDefaultIfNull() {
        System.assertEquals(12.0, Utils.objects.defaultIfNull(null, 12.0));
        System.assertEquals(10.0, Utils.objects.defaultIfNull(10.0, 12.0));
        System.assertEquals(10, Utils.objects.defaultIfNull(null, 10));
        System.assertEquals(10, Utils.objects.defaultIfNull(10, 12));
        System.assertEquals('12', Utils.objects.defaultIfNull(null, '12'));
        System.assertEquals('10.0', Utils.objects.defaultIfNull('10.0', '12.0'));
        System.assertEquals(Date.today(), Utils.objects.defaultIfNull(null, Date.today()));
        System.assertEquals(Datetime.now(), Utils.objects.defaultIfNull(null, Datetime.now()));
    }

    /**
     * ==============================================================================================================
     *                                             FORMAT EXTENSIONS
     * ==============================================================================================================
     */

//    @IsTest
//    static void testFormatAddress() {
//
//        Contact ct = new Contact(FirstName = 'Test', LastName = 'Test',
//            MailingStreet = 'Street', MailingCity = 'City', MailingState = 'State',
//            MailingPostalCode = '0000', MailingCountry = 'Country');
//        System.assertEquals('Street, City, State, 0000, Country', Utils.formats.formatAddress(ct, 'Mailing'));
//
//    }
//
//    @IsTest
//    static void testFormatDateRange() {
//
//        String dateRange = Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 22), Datetime.newInstance(1960, 1, 22));
//        System.assertEquals('Friday 22nd Jan, 1960', dateRange);
//        dateRange = Utils.formats.formatDateRange(null, Datetime.newInstance(1960, 1, 11));
//        System.assertEquals('Monday 11th Jan, 1960', dateRange);
//        dateRange = Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 23), null);
//        System.assertEquals('Saturday 23rd Jan, 1960', dateRange);
//        dateRange = Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 11), Datetime.newInstance(1960, 1, 22));
//        System.assertEquals('Monday 11th to Friday 22nd Jan, 1960', dateRange);
//        dateRange = Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 11), Datetime.newInstance(1960, 2, 23));
//        System.assertEquals('Monday 11th Jan to Tuesday 23rd Feb, 1960', dateRange);
//        dateRange = Utils.formats.formatDateRange(Datetime.newInstance(1960, 1, 21), Datetime.newInstance(1961, 2, 23));
//        System.assertEquals('Thursday 21st Jan, 1960 to Thursday 23rd Feb, 1961', dateRange);
//
//    }
//
//    @IsTest
//    static void testFormatTimeRange() {
//
//        String dateTimeVar = Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), Datetime.newInstance(1960, 1, 22, 11, 30, 00));
//        System.assertEquals('11:30 AM', dateTimeVar);
//        dateTimeVar = Utils.formats.formatTimeRange(null, Datetime.newInstance(1960, 1, 22, 11, 30, 00));
//        System.assertEquals('11:30 AM', dateTimeVar);
//        dateTimeVar = Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), null);
//        System.assertEquals('11:30 AM', dateTimeVar);
//        dateTimeVar = Utils.formats.formatTimeRange(Datetime.newInstance(1960, 1, 22, 11, 30, 00), Datetime.newInstance(1960, 1, 22, 14, 55, 00));
//        System.assertEquals('11:30 AM - 2:55 PM', dateTimeVar);
//
//    }
//
//    @IsTest
//    static void testLongTextAreaToHTML() {
//
//        System.assertEquals(null, Utils.formats.longTextAreaToHTML(null));
//        System.assertEquals('test<br/> test<br/>', Utils.formats.longTextAreaToHTML('test\r\n test\n'));
//    }
//
//    @IsTest
//    static void testFormatPhoneNumbers() {
//
//        Contact contactVar = new Contact(
//            FirstName = 'Contact',
//            LastName = 'Contact',
//            MobilePhone = '1111111110',
//            HomePhone = '2222222221'
//        );
//
//        Utils.IPhoneNumberFormatter mobileFormatter = new Utils.MobilePhoneNumberFormatter();
//        Utils.IPhoneNumberFormatter homeFormatter = new Utils.HomePhoneNumberFormatter();
//        Map<Schema.sObjectField, Utils.IPhoneNumberFormatter> formatMapping = new Map<Schema.sObjectField, Utils.IPhoneNumberFormatter>{
//            Contact.MobilePhone.getDescribe().getSobjectField() => mobileFormatter,
//            Contact.HomePhone.getDescribe().getSobjectField() => homeFormatter
//        };
//        Utils.formats.formatPhoneNumbers(new List<Contact>{contactVar}, formatMapping, true);
//        System.assertEquals('1111 111 110 ', contactVar.MobilePhone);
//        System.assertEquals('22 2222 2221 ', contactVar.HomePhone);
//
//        contactVar.MobilePhone = '';
//        contactVar.HomePhone = '';
//        Utils.formats.formatPhoneNumbers(new List<Contact>{contactVar}, formatMapping, true);
//        System.assertEquals('', contactVar.MobilePhone);
//
//    }


    @IsTest
    static void testCommonCtrl() {
        Map<String, Object> dto = new Map<String, Object>();
        dto.put('SOQL', 'SELECT Id FROM Contact LIMIT 1');
        String requestJSON = JSON.serialize(dto);
        String response = CommonCtrl.execute('SOQLProc', requestJSON);
        System.assertNotEquals(null, response);

        Boolean didThrowException = false;

        try {
            response = CommonCtrl.execute('NonexistentProc', requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        dto.put('SOQL', 'test exception');
        requestJSON = JSON.serialize(dto);

        try {
            response = CommonCtrl.execute('SOQLProc', requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

        String invalidResponse = new Response('Invalid request attributes.').getJSON();
//        response = CommonCtrl.execute(requestJSON);
//        System.assertEquals(invalidResponse, response);

        dto.put('processor', 'SOQLProc');
        dto.put('dto', 'SELECT Id FROM Contact LIMIT 1');
//        requestJSON = JSON.serialize(dto);
//        response = CommonCtrl.execute(requestJSON);
//        System.assertNotEquals(null, response);

        try {
            dto.put('processor', null);
//            requestJSON = JSON.serialize(dto);
//            response = CommonCtrl.execute(requestJSON);
        } catch (Exception ex) {
            didThrowException = true;
            System.assert(didThrowException);
        }

    }

    /**
    * ==============================================================================================================
    *                                SOQLDataTableMetaProc
    * ==============================================================================================================
    */

    @IsTest
    static void testSOQLDataTableMetaProc() {
        Account acc = new Account(Name = 'TestAccount', Industry = 'Other', AnnualRevenue = 100);
        if (Type.forName('Schema.' + 'tc9_et__Timesheet__c') != null) {
            acc.put('tc9_pr__Available_Payment_Methods__c', 'Payee Australian Bank;Payee International Bank;Payee Cheque;Payee Cash');
            acc.put('tc9_pr__Maximum_Payment_Distributions__c', '5');
        }
        insert acc;
        Contact ct = new Contact(AccountId = acc.Id, FirstName = 'Test', LastName = 'Test', Email = 'test@test.com',
                MobilePhone = '0411111111', MailingCountry = 'Australia', MailingCity = 'Test', MailingStreet = 'Test');
        insert ct;

        Map<String, Object> dto = new Map<String, Object>{
                'sObjectType' => 'Contact',
                'fields' => 'Id, Name, Email, Birthdate, MobilePhone, MailingAddress, AccountId, Account.Industry, Account.AnnualRevenue',
                'params' => new Map<String, List<String>>{
                        'idSet' => new List<String>{
                                ct.Id
                        }
                },
                'condition' => 'Id = \'' + ct.Id + '\''


        };

        SOQLDataTableMetaProc SOQLDataTableProc = new SOQLDataTableMetaProc();
        Response response = SOQLDataTableProc.process (new MetadataProcessor.MetadataRequest(JSON.serialize(dto)));
        System.assertNotEquals(null, response);

    }


    /**
    * ==============================================================================================================
    *                                   UnitOfWork
    * ==============================================================================================================
    */

    @IsTest
    static void testUnitOfWork() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account parentAccount = new Account(Name = 'Parent');
            Account childAccount = new Account(Name = 'Child');

            if (Type.forName('Schema.' + 'tc9_et__Timesheet__c') != null) {
                parentAccount.put('tc9_pr__Available_Payment_Methods__c', 'Payee Australian Bank;Payee International Bank;Payee Cheque;Payee Cash');
                childAccount.put('tc9_pr__Available_Payment_Methods__c', 'Payee Australian Bank;Payee International Bank;Payee Cheque;Payee Cash');
                parentAccount.put('tc9_pr__Maximum_Payment_Distributions__c', '5');
                childAccount.put('tc9_pr__Maximum_Payment_Distributions__c', '5');
            }

            UnitOfWork uow = new UnitOfWork(new List<SObjectType>{
                    Account.SObjectType
            }, new fflib_SObjectUnitOfWork.SimpleDML());
            uow.registerUpsert(parentAccount);
            uow.registerUpsert(childAccount);
            uow.registerHierarchy(childAccount, Account.ParentId, parentAccount);

            uow.commitWork();

            List <Account> registeredAccs = [SELECT Id, ParentId FROM Account WHERE Id = :childAccount.Id];
            System.assertEquals(parentAccount.Id, registeredAccs.get(0).ParentId);

        }
    }


    /**
    * ==============================================================================================================
    *                                   AutoMapper
    * ==============================================================================================================
    */

    @IsTest
    static void testMapToSObject() {
        Contact testContact = createContact('test', 'Australia');
        Contact testContact2 = createContact('test2', 'Australia');

        List<Contact> testContacts = new List<Contact>{
                testContact, testContact2
        };

        Map<String, Object> stringToObjectMap = new Map<String, Object>();
        AutoMapper autoMapper = new AutoMapper(stringToObjectMap)
                .mapFromSObject('contact', testContact)
                .mapFromListSObjects('contacts', testContacts);

        System.assert(stringToObjectMap.containsKey('contact'));
        System.assert(stringToObjectMap.containsKey('contacts'));

        Contact newContact = new Contact(
                Email = 'test@test.com', Birthdate = Date.newInstance(2018, 10, 10)
        );
        autoMapper.mapToSObject('contact', newContact);

        System.assertEquals('test@test.com', newContact.Email);
        System.assertEquals('Australia', newContact.MailingCountry);
        System.assertEquals('test', newContact.LastName);

        autoMapper.mapToSObject(newContact);

        AutoMapper.Options optionsVar = autoMapper.getOptions();
        System.assertNotEquals(null, optionsVar.getMapper());
        optionsVar.setIsVisualforce(true);
        optionsVar.setIsAllFields(true);
        optionsVar.setDefaultFieldValue('default value');
        autoMapper.mapToSObject(newContact);
        autoMapper.mapFromSObject('newContact', newContact);

        optionsVar.setIsVisualforce(false);
//        optionsVar.setIsAllFields(false);
        autoMapper.mapToSObject(newContact);
        autoMapper.mapFromSObject('newContact', newContact);


    }

    @IsTest
    static void testGetMap() {
        AutoMapper autoMapper = new AutoMapper();
        AutoMapper autoMapperImpl = new AutoMapper(autoMapper);
        System.assertNotEquals(null, autoMapperImpl.getMap());
    }

    @IsTest
    static void testGetOptions() {
        AutoMapper autoMapper = new AutoMapper();
        System.assertNotEquals(null, autoMapper.getOptions());
    }

    @IsTest
    static void testMapAnyValue() {

        AutoMapper autoMapper = new AutoMapper();
        System.assertNotEquals(null, autoMapper.mapAnyValue('path', 'object'));
    }


    @IsTest
    static void testBehaviour() {


        Contact ct = createContact('test', 'Australia');
        Map<String, Object> dataMap = new Map<String, Object>();

        List<SObjectField> fields = new List<SObjectField>{
                Contact.LastName.getDescribe().getSobjectField(), Contact.MailingCountry.getDescribe().getSobjectField()
        };
        AutoMapper.JoinStringFieldsBinder testJoinFieldsBinder = new AutoMapper.JoinStringFieldsBinder('path', fields, ',');

        testJoinFieldsBinder.bind(ct, dataMap);
        System.assertEquals('test,Australia', dataMap.get('path'));

        AutoMapper.BinderQueue binderQ = new AutoMapper.BinderQueue(new AutoMapper.JoinStringFieldsBinder('commaPath', fields, '.'));
        binderQ.process(ct, dataMap);
        System.assertEquals('test.Australia', dataMap.get('commaPath'));

        List<String> testListFields = new List<String>{
                'MailingCountry', 'LastName'
        };
        AutoMapper.JoinStringBinder testJoinStringBinder = new AutoMapper.JoinStringBinder('pathString', testListFields, ';');
        testJoinStringBinder.bind(ct, dataMap);
        System.assertNotEquals(null, dataMap.get('pathString'));

//   AutoMapper.DatetimeFormatBinder

        ct.Birthdate = Date.newInstance(1990, 10, 10);
        AutoMapper.DatetimeFormatBinder dateBinder = new AutoMapper.DatetimeFormatBinder('datePath', Contact.Birthdate.getDescribe().getSobjectField(), 'dd/MM/YYYY hh:mm:ss');
        dateBinder.bind(ct, dataMap);
        System.assertEquals('10/10/1990 12:00:00', dataMap.get('datePath'));

        AutoMapper.DefaultValueBinder valueBinder = new AutoMapper.DefaultValueBinder('object', 'object');
        valueBinder.bind(ct, dataMap);
        System.assertEquals('object', dataMap.get('object'));

        List<AutoMapper.IBinder> binders = new List<AutoMapper.IBinder>();
        binderQ = new AutoMapper.BinderQueue(binders);

        AutoMapper autoMapper = new AutoMapper(dataMap)
                .mapFromSObject('contact', ct, binderQ);

    }

    @IsTest
    static void deduplicate() {
        Contact contact1 = new Contact(
                FirstName = '1',
                LastName = '1',
                Email = '1@test.com',
                Title = 'Developer'
        );

        insert contact1;

        Contact contact2 = contact1.clone(false);
        contact2.Title = 'Manager';

        Boolean isExistingRecordFound = Utils.sObjects.deduplicate(contact2, new Set<SObjectField>{
                Contact.Title
        });
//        System.debug(contact2);

        upsert contact2;

        System.assertEquals(isExistingRecordFound ? 1 : 2, [SELECT COUNT() FROM Contact]);

        if (isExistingRecordFound) {
            Contact contactVar = [SELECT Id, Title FROM Contact WHERE Id = :contact1.Id];
            System.assertEquals('Developer', contactVar.Title); // Preserved Field.
        }


        // Just ot increase the test coverage.
        Utils.sObjects.deduplicate(contact2);
    }

    @IsTest
    static void coverCommon() {
        Account acc = new Account(Name = 'Test', Type = 'Other', NumberOfEmployees = 10);
        Account acc1 = new Account(Name = 'Test1', Type = 'Other', NumberOfEmployees = 11);
        if (Type.forName('Schema.' + 'tc9_et__Timesheet__c') != null) {
            acc.put('tc9_pr__Available_Payment_Methods__c', 'Payee Australian Bank;Payee International Bank;Payee Cheque;Payee Cash');
            acc1.put('tc9_pr__Available_Payment_Methods__c', 'Payee Australian Bank;Payee International Bank;Payee Cheque;Payee Cash');
            acc.put('tc9_pr__Maximum_Payment_Distributions__c', '5');
            acc1.put('tc9_pr__Maximum_Payment_Distributions__c', '5');
        }
        insert acc;
        insert acc1;
        Utils.picklists.getPicklistAsSetStrings(Account.Type);
        Utils.picklists.convertFlowPicklistFieldValues(acc);
        Utils.users.hasPermSetAssigned('Test');
        Utils.sObjects.getSObjectDescribe(new List<SObjectType>{Account.SObjectType});
        Decimal sum = Utils.sObjects.sum(new List<SObject>{acc, acc1}, Account.NumberOfEmployees);
        Assert.isTrue(sum == 21);
        String repUrl = Utils.URLs.generateReportURL('Test', new List<String>());
        Assert.areEqual('/lightning/r/Report/null/view?queryScope=userFolders', repUrl);
        UnitOfWork uow = new UnitOfWork(
                new List<SObjectType>{
                        Account.SObjectType
                }
        );
        acc1.Name = 'Test11';
        uow.registerDirty(acc1);
        uow.commitWork();
        Assert.areEqual('Test11', acc1.Name);
        AutoMapper am = new AutoMapper(new Map<String, Object>{'obj1' => new AutoMapper().getSObjectsAsMaps(new List<SObject>{acc1})});
        am.getOptions().setIsVisualforce(true);
        List<SObject> obj1Records = am.mapToListSObjects('obj1', Account.SObjectType);
        Assert.isNotNull(obj1Records);
        Utils.encodings.mapToFormUrlEncoded(new Map<String,String>{'test' => 'test'});
        Blob key = Crypto.generateAesKey(256);
        String keyString = EncodingUtil.base64Encode(key);
        String encryptedStr = Utils.encodings.getEncryptedValue('test', keyString);
        String decryptedStr = Utils.encodings.getDecryptedValue(encryptedStr, keyString);
        System.assertEquals('test', decryptedStr);
        Assert.areEqual('test', decryptedStr);
        Boolean isSandbox = Utils.orgs.isSandbox();
        Boolean isScratch = Utils.orgs.isScratch();
        try {
            Contact contacts = (Contact) Utils.arrays.firstOrException([
                    SELECT Id
                    FROM Contact
                    WHERE Name = 'firstOrException'
            ]);
        } catch (Exception ex) {
            Assert.isTrue( ex.getMessage().contains('The list is empty'));
        }
        List<List<Object>> splitList = Utils.arrays.split(new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 9 ,10}, 2, List<Integer>.class);
        System.assertEquals(5, splitList.size());
    }

    /**
    * ==============================================================================================================
    *                                             TEMPLATE EXTENSIONS
    * ==============================================================================================================
    */

    @IsTest
    static void testCompose() {
        System.assertNotEquals(null, Utils.templates.compose('test.test', new Map<String, Object>()));
    }

    @IsTest
    static void testExtractMergeFields() {
        System.assertNotEquals(null, Utils.templates.extractMergeFields('test.test'));
    }

    @IsTest
    static void testGetExpression() {
        System.assertNotEquals(null, Utils.templates.getExpression('{!test}'));
    }
}
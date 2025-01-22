@IsTest
private class NDISProductManagGetAvailableItemProcTest {
    static testMethod void testBehavior() {

        setupData();

        Pricebook2 pricebook2Var = [SELECT Id FROM Pricebook2 LIMIT 1];
        Product2 productVar = [SELECT Id, Support_Item_Number__c FROM Product2 LIMIT 1];
        maica_cc__Support_Category__c supportCategory = [SELECT Id FROM maica_cc__Support_Category__c LIMIT 1];
        maica_cc__Funding__c planVar = [SELECT Id FROM maica_cc__Funding__c LIMIT 1];

        //serviceDate == 'Weekday'
        Request requestVar = new Request();
        requestVar.put('filter', new Map<String, Object>{
                'serviceDay' => 'Weekday',
                'serviceTime' => 'Daytime',
                'productName' => productVar.Support_Item_Number__c,
                'supportCategoryId' => supportCategory.Id,
                'pricebookId' => pricebook2Var.Id,
                'activePlanId' => planVar.Id,
                'isEnforceActivePlan' => true
        });

        Response responseVar = new NDISProductManagGetAvailableItemsProc().process(requestVar);
        List<PricebookEntry> items = (List<PricebookEntry>) responseVar.getMapper().mapToListSObjects('items.records', PricebookEntry.SObjectType);

        System.assert(responseVar.isValid);
    }

    static void setupData() {
        Contact contactVar = new Contact(
                LastName = 'Test Contact',
                maica_cc__NDIS_Number__c = '123456789'

        );
        insert contactVar;

        maica_cc__Funding__c planVar = new maica_cc__Funding__c(
                maica_cc__NDIS_Reference__c = '1234',
                maica_cc__Participant__c = contactVar.Id
        );
        insert planVar;

        maica_cc__Support_Category__c supportCategoryVar = new maica_cc__Support_Category__c(
                maica_cc__Support_Purpose__c = 'Core',
                maica_cc__NDIS_Name__c = 'test'
        );
        insert supportCategoryVar;

        maica_cc__Funding_Item__c budgetVar = new maica_cc__Funding_Item__c(
                maica_cc__Funding__c = planVar.Id,
                maica_cc__Remaining_Amount__c = 10,
                maica_cc__Support_Category__c = supportCategoryVar.Id
        );
        insert budgetVar;

        Product2 productVar = new Product2(
                Name = 'testProduct',
                Support_Item_Number__c = '1234',
                Service_Day__c = 'Weekday',
                Service_Time__c = 'Daytime',
                Support_Category__c = supportCategoryVar.Id
        );
        insert productVar;

        maica_cc__Service_Booking__c serviceBookingVar = new maica_cc__Service_Booking__c(
                maica_cc__Participant__c = contactVar.Id,
                maica_cc__Funding__c = planVar.Id,
                maica_cc__NDIS_Reference__c = 'asdf'
        );
        insert serviceBookingVar;

        maica_cc__Booking_Item__c bookingItem = new maica_cc__Booking_Item__c(
                maica_cc__Service_Booking__c = serviceBookingVar.Id,
                maica_cc__Support_Category__c = supportCategoryVar.Id,
                maica_cc__Support_Item__c = productVar.Id,
                maica_cc__Remaining_Amount__c = 1
        );
        insert bookingItem;

        PricebookEntry pricebookEntryVar = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar.Id
        );
        insert pricebookEntryVar;
    }
}
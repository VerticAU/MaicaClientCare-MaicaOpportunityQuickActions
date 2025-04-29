@IsTest
private class NDISProductManagementQATest {
    //oppVar.NDIS_Funding__c == null
    static testMethod void testMetaProc() {

        setupData();

        maica_cc__Funding__c planVar = [SELECT Id FROM maica_cc__Funding__c LIMIT 1];
        Product2 productVar = [SELECT Id FROM Product2 LIMIT 1];
        Opportunity oppVarNullPlan = [SELECT Id, Pricebook2Id FROM Opportunity WHERE NDIS_Funding__c = NULL LIMIT 1];
        Opportunity oppVarNotNullPlan = [SELECT Id FROM Opportunity WHERE NDIS_Funding__c != NULL LIMIT 1];
        Opportunity oppVarNullParticipant = [SELECT Id FROM Opportunity WHERE Participant__c = NULL LIMIT 1];

        //Opportunity with NDIS_Funding__c == null
        MetadataProcessor.MetadataRequest requestVarNullPlan = new MetadataProcessor.MetadataRequest(
            JSON.serialize(
                new Map<String, Object>{
                    'recordId' => oppVarNullPlan.Id

                }
            )
        );
        Response responseVarNullPlan = new NDISProductManagementQAMetaProc().process(requestVarNullPlan);


        //Opportunity with NDIS_Funding__c != null
        MetadataProcessor.MetadataRequest requestVarNotNullPlan = new MetadataProcessor.MetadataRequest(
            JSON.serialize(
                new Map<String, Object>{
                    'recordId' => oppVarNotNullPlan.Id

                }
            )
        );
        Response responseVarNotNullPlan = new NDISProductManagementQAMetaProc().process(requestVarNotNullPlan);

        //oppVar.maica__Participant__c != planVar.Participant__c (Active Plan)
        MetadataProcessor.MetadataRequest requestVarNullParticipant = new MetadataProcessor.MetadataRequest(
            JSON.serialize(
                new Map<String, Object>{
                    'recordId' => oppVarNullParticipant.Id

                }
            )
        );
        try {
            Response responseVarNullParticipant = new NDISProductManagementQAMetaProc().process(requestVarNullParticipant);

        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'Primary Contact on Opportunity is different to Participant on associated NDIS Plan');
        }

    }

    static testMethod void testSubmitProcWithPriceListEntry() {
        setupData();

//        Pricebook2 priceList = [SELECT Id FROM Pricebook2 LIMIT 1];
        maica_cc__Funding__c planVar = [SELECT Id FROM maica_cc__Funding__c LIMIT 1];
        Product2 productVar = [SELECT Id FROM Product2 LIMIT 1];
        Opportunity oppVarNullPlan = [SELECT Id, Pricebook2Id FROM Opportunity WHERE NDIS_Funding__c = NULL LIMIT 1];

//        PricebookEntry pricebookEntryVar = new PricebookEntry(
//            UnitPrice = 10,
//            IsActive = true,
//            Pricebook2Id = Test.getStandardPricebookId(),
//            Product2Id = productVar.Id
//        );
//        insert pricebookEntryVar;

        Request requestVarNotNullPriceListEntry = new Request(new Map<String, Object>{
            'recordId' => oppVarNullPlan.Id,
            'activePlanId' => planVar.Id,
            'items' => new List<Object>{
                new Map<String, Object>{
                    'Id' => '',
                    'UnitPrice' => '1',
                    'Product2Id' => productVar.Id,
                    'Quantity' => 1,
                    'TotalPrice' => 1
                }
            }
        });

        Response responseVarNotNullPriceListEntry = new NDISProductManagementQASubmitProc().process(requestVarNotNullPriceListEntry);
        System.assert(responseVarNotNullPriceListEntry.isValid);
    }

    static testMethod void testSubmitProcWithoutPriceListEntry() {
        setupData();

        maica_cc__Funding__c planVar = [SELECT Id FROM maica_cc__Funding__c LIMIT 1];
        Product2 productVar = [SELECT Id FROM Product2 LIMIT 1];
        Opportunity oppVarNullPlan = [SELECT Id, Pricebook2Id FROM Opportunity WHERE NDIS_Funding__c = NULL LIMIT 1];

        Request requestVarNotNullPriceListEntry = new Request(new Map<String, Object>{
            'recordId' => oppVarNullPlan.Id,
            'activePlanId' => planVar.Id,
            'items' => new List<Object>{
                new Map<String, Object>{
                    'Id' => '',
                    'UnitPrice' => '1',
                    'Product2Id' => productVar.Id,
                    'Quantity' => 1,
                    'TotalPrice' => 1
                }
            }
        });

        Response responseVarNotNullPriceListEntry = new NDISProductManagementQASubmitProc().process(requestVarNotNullPriceListEntry);
        System.assert(responseVarNotNullPriceListEntry.isValid);
    }

    static void setupData() {
        Contact contactVar = new Contact(
            LastName = 'Test Contact'
        );
        insert contactVar;

        maica_cc__Funding__c planVar = new maica_cc__Funding__c(
            maica_cc__Participant__c = contactVar.Id,
            maica_cc__End_Date__c = Date.today(),
            maica_cc__Start_Date__c = Date.newInstance(2021, 10, 26),
            maica_cc__Funding_Source__c = 'Home Care Package'
        );
        insert planVar;

        maica_cc__Support_Category__c supportCategoryVar = new maica_cc__Support_Category__c();
        insert supportCategoryVar;

        maica_cc__Service_Booking__c serviceBookingVar = new maica_cc__Service_Booking__c(
            maica_cc__Participant__c = contactVar.Id,
            maica_cc__Funding__c = planVar.Id
        );
        insert serviceBookingVar;

        maica_cc__Booking_Item__c serviceItemVar = new maica_cc__Booking_Item__c(
            maica_cc__Service_Booking__c = serviceBookingVar.Id,
            maica_cc__Support_Category__c = supportCategoryVar.Id,
            maica_cc__Remaining_Amount__c = 1
        );
        insert serviceItemVar;

        //Opportunity with NDIS_Funding__c == null
        Opportunity oppVar = new Opportunity(
            Name = 'Test Opp',
            StageName = 'New',
            CloseDate = Date.today() + 1,
            Pricebook2Id = Test.getStandardPricebookId(),
            Participant__c = contactVar.Id,
            Funding_Source__c = 'Home Care Package'
        );
        insert oppVar;

        //Opportunity with NDIS_Funding__c != null
        Opportunity oppVar1 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'New',
            CloseDate = Date.today() + 1,
            Pricebook2Id = Test.getStandardPricebookId(),
            Participant__c = contactVar.Id,
            NDIS_Funding__c = planVar.Id,
            Funding_Source__c = 'Home Care Package'
        );
        insert oppVar1;

        //oppVar.maica__Participant__c != planVar.Participant__c (Active Plan)
        Opportunity oppVar2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'New',
            CloseDate = Date.today() + 1,
            Pricebook2Id = Test.getStandardPricebookId(),
            NDIS_Funding__c = planVar.Id,
            Funding_Source__c = 'Home Care Package'
        );
        insert oppVar2;

        Product2 productVar = new Product2(
            Name = 'testProduct',
            Support_Category__c = supportCategoryVar.Id
        );
        insert productVar;
    }

}
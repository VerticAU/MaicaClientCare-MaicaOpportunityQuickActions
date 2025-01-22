@IsTest
private class NDISProductManagementCalcProcTest {

    static testMethod void testBehavior() {

        setupData();

        Opportunity oppVar = (Opportunity) Utils.arrays.firstOrException(
                [SELECT Id FROM Opportunity],
                'No existing Opportunity'
        );

        OpportunityLineItem oppLineItemFrequencyOne = (OpportunityLineItem) Utils.arrays.firstOrException(
                [SELECT Id, Service_Frequency__c, Start_Date__c, End_Date__c FROM OpportunityLineItem WHERE Service_Frequency__c = 'One'],
                'No existing OpportunityLineItem with Service_Frequency__c = \'One\''
        );
        OpportunityLineItem oppLineItemFrequencyDay = (OpportunityLineItem) Utils.arrays.firstOrException(
                [SELECT Id, Service_Frequency__c, Start_Date__c, End_Date__c, Product2Id FROM OpportunityLineItem WHERE Service_Frequency__c = 'Day'],
                'No existing OpportunityLineItem with Service_Frequency__c = \'Day\''
        );
        OpportunityLineItem oppLineItemFrequencyWeek = (OpportunityLineItem) Utils.arrays.firstOrException(
                [SELECT Id, Service_Day__c, Schedule_Count__c, Schedule_Day__c, Service_Frequency__c, Start_Date__c, End_Date__c FROM OpportunityLineItem WHERE Service_Frequency__c = 'Week'],
                'No existing OpportunityLineItem with Service_Frequency__c = \'Week\''
        );
        OpportunityLineItem oppLineItemFrequencyMonth = (OpportunityLineItem) Utils.arrays.firstOrException(
                [SELECT Id, Service_Frequency__c, Start_Date__c, End_Date__c FROM OpportunityLineItem WHERE Service_Frequency__c = 'Month'],
                'No existing OpportunityLineItem with Service_Frequency__c = \'Month\''
        );
        OpportunityLineItem oppLineItemFrequencyPH = (OpportunityLineItem) Utils.arrays.firstOrException(
                [SELECT Id, Service_Frequency__c, Start_Date__c, End_Date__c, Service_Day__c FROM OpportunityLineItem WHERE Service_Day__c = 'Public Holiday'],
                'No existing OpportunityLineItem with Service_Day__c = \'Public Holiday\''
        );

        Request requestVar = new Request();
        requestVar.put('opportunityId', oppVar.Id);

        requestVar.getMapper().mapFromSObject('item', oppLineItemFrequencyOne);
        Response responseVarFrequencyOne = new NDISProductManagementCalcProc().process(requestVar);

        requestVar.getMapper().mapFromSObject('item', oppLineItemFrequencyDay);
        Response responseVarFrequencyDay = new NDISProductManagementCalcProc().process(requestVar);

        requestVar.getMapper().mapFromSObject('item', oppLineItemFrequencyWeek);
        Response responseVarFrequencyWeek = new NDISProductManagementCalcProc().process(requestVar);

        requestVar.getMapper().mapFromSObject('item', oppLineItemFrequencyMonth);
        Response responseVarFrequencyMonth = new NDISProductManagementCalcProc().process(requestVar);

        requestVar.getMapper().mapFromSObject('item', oppLineItemFrequencyPH);
        Response responseVarFrequencyPH = new NDISProductManagementCalcProc().process(requestVar);

        System.assertEquals(1, responseVarFrequencyOne.getInteger('quantity'));
        System.assertEquals(2, responseVarFrequencyDay.getInteger('quantity'));
        System.assertEquals(3, responseVarFrequencyWeek.getInteger('quantity'));
        System.assertEquals(2, responseVarFrequencyMonth.getInteger('quantity'));
    }

    static void setupData() {
        Product2 productVar = new Product2(
                Name = 'testProduct'
        );
        insert productVar;

        Opportunity oppVar = new Opportunity(
                Name = 'testOpp',
                CloseDate = Date.today(),
                StageName = 'Closed Won'
        );
        insert oppVar;

        PricebookEntry pricebookEntryVar = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar.Id
        );
        insert pricebookEntryVar;

        OpportunityLineItem oppLineItemFrequencyOne = new OpportunityLineItem(
                OpportunityId = oppVar.Id,
                Quantity = 1,
                TotalPrice = 1,
                Service_Frequency__c = 'One',
                PricebookEntryId = pricebookEntryVar.Id,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today() + 1
        );
        insert oppLineItemFrequencyOne;

        OpportunityLineItem oppLineItemFrequencyDay = new OpportunityLineItem(
                OpportunityId = oppVar.Id,
                Quantity = 1,
                TotalPrice = 1,
                Service_Frequency__c = 'Day',
                Start_Date__c = Date.today(),
                End_Date__c = Date.today() + 1,
                PricebookEntryId = pricebookEntryVar.Id,
                Product2Id = productVar.Id
        );
        insert oppLineItemFrequencyDay;

        OpportunityLineItem oppLineItemFrequencyWeek = new OpportunityLineItem(
                OpportunityId = oppVar.Id,
                Quantity = 1,
                TotalPrice = 1,
                Service_Frequency__c = 'Week',
                Schedule_Day__c = 'Monday',
                Schedule_Count__c = 2,
                Start_Date__c = Date.newInstance(2022, 7, 25),
                End_Date__c = Date.newInstance(2022, 8, 25),
                PricebookEntryId = pricebookEntryVar.Id
        );
        insert oppLineItemFrequencyWeek;

        OpportunityLineItem oppLineItemFrequencyMonth = new OpportunityLineItem(
                OpportunityId = oppVar.Id,
                Quantity = 1,
                TotalPrice = 1,
                Service_Frequency__c = 'Month',
                Start_Date__c = Date.newInstance(2022, 7, 25),
                End_Date__c = Date.newInstance(2022, 8, 25),
                PricebookEntryId = pricebookEntryVar.Id
        );
        insert oppLineItemFrequencyMonth;

        OpportunityLineItem oppLineItemFrequencyPH = new OpportunityLineItem(
                OpportunityId = oppVar.Id,
                Quantity = 1,
                TotalPrice = 1,
                Start_Date__c = Date.newInstance(2022, 3, 22),
                End_Date__c = Date.newInstance(2022, 4, 23),
                PricebookEntryId = pricebookEntryVar.Id,
                Service_Day__c = 'Public Holiday'
        );
        insert oppLineItemFrequencyPH;
    }

}
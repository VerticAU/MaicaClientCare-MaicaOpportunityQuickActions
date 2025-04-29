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
        maica_cc__Support_Category__c supportCategory = new maica_cc__Support_Category__c(
            Name = 'Test'
        );
        insert supportCategory;

        Product2 productVar = new Product2(
            Name = 'testProduct',
            Support_Category__c = supportCategory.Id
        );
        insert productVar;

        Product2 productVar1 = new Product2(
                Name = 'testProduct1',
                Support_Category__c = supportCategory.Id
        );
        insert productVar1;

        Product2 productVar2 = new Product2(
                Name = 'testProduct2',
                Support_Category__c = supportCategory.Id
        );
        insert productVar2;

        Product2 productVar3 = new Product2(
                Name = 'testProduct3',
                Support_Category__c = supportCategory.Id
        );
        insert productVar3;

        Product2 productVar4 = new Product2(
                Name = 'testProduct4',
                Support_Category__c = supportCategory.Id
        );
        insert productVar4;

        Opportunity oppVar = new Opportunity(
            Name = 'testOpp',
            CloseDate = Date.today() + 1,
            StageName = 'New',
            Funding_Source__c = 'Home Care Package'
        );
        insert oppVar;

        PricebookEntry pricebookEntryVar = new PricebookEntry(
            UnitPrice = 10,
            IsActive = true,
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productVar.Id
        );
        insert pricebookEntryVar;

        PricebookEntry pricebookEntryVar1 = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar1.Id
        );
        insert pricebookEntryVar1;

        PricebookEntry pricebookEntryVar2 = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar2.Id
        );
        insert pricebookEntryVar2;

        PricebookEntry pricebookEntryVar3 = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar3.Id
        );
        insert pricebookEntryVar3;

        PricebookEntry pricebookEntryVar4 = new PricebookEntry(
                UnitPrice = 10,
                IsActive = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = productVar4.Id
        );
        insert pricebookEntryVar4;

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
            PricebookEntryId = pricebookEntryVar1.Id,
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
            PricebookEntryId = pricebookEntryVar2.Id
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
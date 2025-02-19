@IsTest
private class CreateServiceAgreementOnOppQATest {
    static testmethod void testMetaAndSubmitProc() {

        setupData();

        Opportunity opportunityVar = (Opportunity) Utils.arrays.firstOrException(
            [SELECT Id, Agreement_Start_Date__c, Agreement_End_Date__c, Pricebook2Id FROM Opportunity],
            'No existing Opportunity'
        );

        MetadataProcessor.MetadataRequest requestVarForMetaProc = new MetadataProcessor.MetadataRequest(
            JSON.serialize(
                new Map<String, Object>{
                    'recordId' => opportunityVar.Id
                }
            )
        );

        Response responseVarFromMetaProc = new CreateServiceAgreementOnOppQAMetaProc().process(requestVarForMetaProc);
        System.assert(responseVarFromMetaProc.isValid);

        Request requestVarForSubmitProc = new Request();
        requestVarForSubmitProc.getMapper()
            .mapFromSObject('serviceAgreement', (maica_cc__Service_Agreement__c) responseVarFromMetaProc.get('serviceAgreement'));

        requestVarForSubmitProc.put('agreementItems', responseVarFromMetaProc.get('agreementItems'));

        Response responseVarFromSubmitProc = new CreateServiceAgreementOnOppQASubmitProc().process(requestVarForSubmitProc);

        maica_cc__Service_Agreement__c serviceAgreementVar = (maica_cc__Service_Agreement__c) Utils.arrays.firstOrException(
            [SELECT Id, maica_cc__Start_Date__c, maica_cc__End_Date__c, maica_cc__Price_List__c FROM maica_cc__Service_Agreement__c],
            'No existing maica_cc__Service_Agreement__c'
        );

        maica_cc__Agreement_Item__c agreementItemVar = (maica_cc__Agreement_Item__c) Utils.arrays.firstOrException(
            [SELECT Id, maica_cc__Start_Date__c, maica_cc__End_Date__c FROM maica_cc__Agreement_Item__c],
            'No existing maica_cc__Agreement_Item__c'
        );

        System.assert(responseVarFromSubmitProc.isValid);
        System.assertEquals(serviceAgreementVar.maica_cc__Start_Date__c, opportunityVar.Agreement_Start_Date__c);
        System.assertEquals(serviceAgreementVar.maica_cc__End_Date__c, opportunityVar.Agreement_End_Date__c);
        System.assertEquals(agreementItemVar.maica_cc__Start_Date__c, serviceAgreementVar.maica_cc__Start_Date__c);
        System.assertEquals(agreementItemVar.maica_cc__End_Date__c, serviceAgreementVar.maica_cc__End_Date__c);
    }

    static void setupData() {
        Account fundAdmin = new Account(
            Name = 'Funding Administrator'
        );
        insert fundAdmin;
        Opportunity opportunityVar = new Opportunity(
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Name = 'testOpp',
            Agreement_Start_Date__c = Date.today(),
            Agreement_End_Date__c = Date.today() + 1,
            Pricebook2Id = Test.getStandardPricebookId(),
            Funding_Source__c = 'Home Care Package',
            Funding_Administrator__c = fundAdmin.Id,
            Funding_Type__c = 'Home Care Package',
            AccountId = fundAdmin.Id
        );
        insert opportunityVar;

        maica_cc__Support_Category__c supportCategory = new maica_cc__Support_Category__c(
            Name = 'Test'
        );
        insert supportCategory;

        Product2 productVar = new Product2(
            Name = 'testProduct',
            Support_Category__c = supportCategory.Id
        );
        insert productVar;

        maica_cc__Price_List__c priceList = new maica_cc__Price_List__c(
            Price_Book__c = opportunityVar.Pricebook2Id
        );
        insert priceList;

        update new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Price_List__c = priceList.Id
        );

        PricebookEntry pricebookEntryVar = new PricebookEntry(
            UnitPrice = 10,
            IsActive = true,
            UseStandardPrice = false,
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productVar.Id
        );
        insert pricebookEntryVar;

        OpportunityLineItem opportunityLineItemVar = new OpportunityLineItem(
            PricebookEntryId = pricebookEntryVar.Id,
            OpportunityId = opportunityVar.Id,
            UnitPrice = 1,
            Quantity = 1
        );
        insert opportunityLineItemVar;
    }
}
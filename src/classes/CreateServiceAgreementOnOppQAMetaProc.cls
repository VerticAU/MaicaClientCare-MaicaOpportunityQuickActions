//SECURED!
public with sharing class CreateServiceAgreementOnOppQAMetaProc extends MetadataProcessor {

    public override Response process(Request request) {
        this.request = request == null ? new MetadataProcessor.MetadataRequest() : (MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                maica_cc__Agreement_Item__c.maica_cc__Funding_Type__c
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');
        Opportunity opportunityVar = (Opportunity) Utils.arrays.firstOrException([
                SELECT Id, Agreement_Start_Date__c, Agreement_End_Date__c, Pricebook2Id, StageName,
                        Participant__c, Participant__r.FirstName, Participant__r.LastName, AccountId, Funding_Type__c,
                        Pricebook2.Name
                FROM Opportunity
                WHERE Id = :recordId
                WITH USER_MODE
        ], 'No Opportunity with Id: ' + recordId);
        Utils.objects.throwIfNull(opportunityVar.Pricebook2Id, 'Please associate a Price Book with the Opportunity');

        maica_cc__Price_List__c priceListVar = (maica_cc__Price_List__c) Utils.arrays.firstOrException([
                SELECT Id
                FROM maica_cc__Price_List__c
                WHERE Price_Book__c = :opportunityVar.Pricebook2Id
        ], 'No related Price List with Price_Book__c: ' + opportunityVar.Pricebook2Id);

        maica_cc__Funding__c activePacePlanVar = opportunityVar.Participant__c == null ? null : getActivePacePlan(opportunityVar.Participant__c);

        maica_cc__Service_Agreement__c serviceAgreementVar = new maica_cc__Service_Agreement__c(
                maica_cc__Start_Date__c = opportunityVar.Agreement_Start_Date__c,
                maica_cc__End_Date__c = opportunityVar.Agreement_End_Date__c,
                maica_cc__Price_List__c = priceListVar.Id,
                Related_Opportunity__c = opportunityVar.Id,
                maica_cc__Participant__c = opportunityVar.Participant__c,
                maica_cc__Service_Provider__c = opportunityVar.AccountId,
                maica_cc__Funding_Type__c = opportunityVar.Funding_Type__c,
                Name = Utils.strings.joinNonBlank(new List<String>{
                        'Service Agreement', opportunityVar.Participant__r?.FirstName, opportunityVar.Participant__r?.LastName
                }, ' ')
        );

        List<OpportunityLineItem> oppLineItems = [
                SELECT Product2Id, Product2.Name, Product2.Support_Category__c, Quantity, UnitPrice,
                        Schedule_Count__c, Schedule_Day__c,
                        Service_Frequency__c, Service_Day__c, Service_Time__c,
                        Service_Duration__c, Allow_Support_Item_Change__c, Funding_Type__c,
                        Product2.Category_Funding__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :recordId
                WITH USER_MODE
        ];

        Set<Id> productIds = Utils.sObjects.getIdFieldValues(oppLineItems), OpportunityLineItem.Product2Id);
        List<maica_cc__Support_Item__c> supportItems = [
                SELECT Id, Name, maica_cc__Support_Category__c, maica_cc__Service_Day__c, maica_cc__Service_Time__c,
                        maica_cc__Quantity_Unit_Of_Measure__c
                FROM maica_cc__Support_Item__c
                WHERE Product__c IN :productIds
        ];
        Map<String, SObject> supportItemsByProduct = Utils.sObjects.getSObjectsByAnyFieldMap(supportItems, maica_cc__Support_Item__c.Product__c);

        List<Map<String, Object>> agreementItems = new List<Map<String, Object>>();

        for (OpportunityLineItem item : oppLineItems) {
            agreementItems.add(new Map<String, Object>{
                    'maica_cc__Support_Item__c' => supportItemsByProduct.get(item.Product2Id)?.Id,
                    'maica_cc__Support_Item__r' => supportItemsByProduct.get(item.Product2Id),
                    'maica_cc__Quantity__c' => item.Quantity,
                    'maica_cc__Rate__c' => item.UnitPrice,
                    'maica_cc__Schedule_Count__c' => item.Schedule_Count__c,
                    'maica_cc__Schedule_Day__c' => item.Schedule_Day__c,
                    'maica_cc__Service_Day__c' => item.Service_Day__c,
                    'maica_cc__Service_Duration__c' => item.Service_Duration__c,
                    'maica_cc__Service_Frequency__c' => item.Service_Frequency__c,
                    'maica_cc__Service_Time__c' => item.Service_Time__c,
                    'maica_cc__Allow_Support_Item_Change__c' => item.Allow_Support_Item_Change__c,
                    'maica_cc__Funding_Type__c' => item.Funding_Type__c,
                    'oppLineItemId' => item.Id
            });
        }

        Map<String, Map<String, Object>> oppLineItemsMap = new Map<String, Map<String, Object>>();
        List<Map<String, Object>> oppLineItemsAsMaps = new AutoMapper().getSObjectsAsMaps(oppLineItems);
        for(Map<String, Object> oppLineItem : oppLineItemsAsMaps){
            oppLineItem.put('supportItemId',  supportItemsByProduct?.get((String) oppLineItem.get('Product2Id'))?.Id);
            oppLineItem.put('supportItem', supportItemsByProduct?.get((String) oppLineItem.get('Product2Id')));
            oppLineItemsMap.put((String) oppLineItem.get('Id'), oppLineItem);
        }

        maica_cc__Service_Agreement__c existedAgreement = (maica_cc__Service_Agreement__c) Utils.arrays.firstOrNull(
                [SELECT Id FROM maica_cc__Service_Agreement__c WHERE Related_Opportunity__c = :recordId AND maica_cc__Status__c = 'Active' WITH USER_MODE]
        );

        this.response.put('existedAgreement', existedAgreement);
        this.response.put('oppLineItemsMap', oppLineItemsMap);
        this.response.put('serviceAgreement', serviceAgreementVar);
        this.response.put('agreementItems', agreementItems);
        this.response.put('isCombinationFunding', 'Combination'.equalsIgnoreCase(opportunityVar.Funding_Type__c));
        this.response.selectOptions.put('oppLineItemsOptions', new List<Structs.SelectOption>());
    }

    public static maica_cc__Funding__c getActivePacePlan(String participantId) {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(maica_cc__Funding__c.SObjectType);
        queryFactory.selectFields('Id,maica_cc__PACE_Funding__c,maica_cc__End_Date__c'.split(','));
        queryFactory.setCondition('maica_cc__Participant__c = :participantId AND maica_cc__Active__c = TRUE AND maica_cc__PACE_Funding__c = TRUE');
        queryFactory.setSecurityEnforced(false);
        queryFactory.setLimit(1);
        maica_cc__Funding__c activePacePlanVar = (maica_cc__Funding__c) Utils.arrays.firstOrNull(Database.query(queryFactory.toSOQL()));
        return activePacePlanVar;
    }
}
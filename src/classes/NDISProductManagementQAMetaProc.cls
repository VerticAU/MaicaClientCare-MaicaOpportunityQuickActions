//SECURED!
@NamespaceAccessible
public with sharing class NDISProductManagementQAMetaProc extends MetadataProcessor {
    @NamespaceAccessible
    public override Response process(Request request) {
        this.request = request == null ? new MetadataProcessor.MetadataRequest() : (MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                OpportunityLineItem.Service_Frequency__c,
                OpportunityLineItem.Service_Day__c,
                OpportunityLineItem.Service_Time__c,
                OpportunityLineItem.Schedule_Day__c,
                OpportunityLineItem.Funding_Type__c
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private Opportunity oppVar;

    private void init() {

        String opportunityId = this.request.getRequiredString('recordId');

        oppVar = (Opportunity) Utils.arrays.firstOrException([
                SELECT Id, Participant__c, AccountId, Pricebook2Id, Funding__c, Agreement_Start_Date__c, Agreement_End_Date__c, Funding_Type__c
                FROM Opportunity
                WHERE Id = :opportunityId
                WITH USER_MODE
        ],
                'No Opportunity with Id: ' + opportunityId
        );
        this.response.put('opportunity', oppVar);
        this.response.put('isCombinationFunding', 'Combination'.equalsIgnoreCase(oppVar.Funding_Type__c));

        Utils.objects.throwIfBlank(oppVar.Pricebook2Id, 'Please assign the Pricebook to the Opportunity.');

        this.initPlanAndCategoriesTotalRemaining();

        List<OpportunityLineItem> items = [
                SELECT Id, Support_Category__c, Product2Id, Quantity, ListPrice, UnitPrice,
                        Product2.Id, Product2.Name, Product2.Support_Item_Number__c,
                        Product2.Support_Category__c, Product2.Support_Category__r.Name,
                        Product2.Support_Category__r.maica_cc__Support_Purpose__c, Product2.Bucket__c,
                        Start_Date__c, End_Date__c, Schedule_Count__c, Schedule_Day__c,
                        Service_Day__c, Service_Time__c, Period_Type__c,
                        TotalPrice, PricebookEntryId, Funding_Type__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
                WITH USER_MODE
        ];

        this.response.put('items', items);

        this.response.selectOptions.put('periodTypeOptions', Utils.picklists.getPicklistValuesAsSelectOptions(OpportunityLineItem.Period_Type__c, new Set<String>{
                oppVar.Agreement_Start_Date__c == null || oppVar.Agreement_End_Date__c == null ? 'Agreement' : null,
                oppVar.Funding__c == null ? 'Plan' : null
        }));

        List<Structs.SelectOption> weekdayOptions = new List<Structs.SelectOption>{
                new Structs.SelectOption('Monday'),
                new Structs.SelectOption('Tuesday'),
                new Structs.SelectOption('Wednesday'),
                new Structs.SelectOption('Thursday'),
                new Structs.SelectOption('Friday')
        };

        List<Structs.SelectOption> serviceFrequencyWithoutPublicHolidayOptions = new List<Structs.SelectOption>{
                new Structs.SelectOption('Day', 'Daily'),
                new Structs.SelectOption('Week', 'Weekly'),
                new Structs.SelectOption('Month', 'Monthly'),
                new Structs.SelectOption('One', 'One Time')
        };

        List<Structs.SelectOption> serviceFrequencyWithoutDailyAndPublicHolidayOptions = new List<Structs.SelectOption>{
                new Structs.SelectOption('Week', 'Weekly'),
                new Structs.SelectOption('Month', 'Monthly'),
                new Structs.SelectOption('One', 'One Time')
        };

        this.response.selectOptions.put('weekdayOptions', weekdayOptions);
        this.response.selectOptions.put('serviceFrequencyWithoutPublicHolidayOptions', serviceFrequencyWithoutPublicHolidayOptions);
        this.response.selectOptions.put('serviceFrequencyWithoutDailyAndPublicHolidayOptions', serviceFrequencyWithoutDailyAndPublicHolidayOptions);
    }

    private void initPlanAndCategoriesTotalRemaining() {
        maica_cc__Funding__c activePlan = (maica_cc__Funding__c) Utils.arrays.firstOrNull([
                SELECT Id, Name, maica_cc__Participant__c, maica_cc__Last_NDIS_Sync__c, maica_cc__Start_Date__c, maica_cc__End_Date__c
                FROM maica_cc__Funding__c
                WHERE Id = :oppVar.Funding__c
                WITH USER_MODE
        ]);

        if (activePlan == null) {
            this.response.put('hasActivePlan', false);
            return;
        }

        if (oppVar.Participant__c != activePlan.maica_cc__Participant__c) {
            throw new Structs.ValidationException('Primary Contact on Opportunity is different to Participant on associated NDIS Plan');
        }

        List<maica_cc__Funding_Item__c> planBudgets = [
                SELECT Id, Name, maica_cc__Support_Category__c, maica_cc__Approved_Amount__c, maica_cc__Remaining_Amount__c
                FROM maica_cc__Funding_Item__c
                WHERE maica_cc__Funding__c = :activePlan.Id
                WITH USER_MODE
        ];
        Map<String, List<SObject>> budgetsByCategory = Utils.sObjects.getSObjectsListByAnyFieldMap(planBudgets, maica_cc__Funding_Item__c.maica_cc__Support_Category__c);

        List<AggregateResult> totals = [
                SELECT maica_cc__Support_Category__c Support_Category__c, SUM(maica_cc__Remaining_Amount__c) Remaining_Amount__c
                FROM maica_cc__Funding_Item__c
                WHERE maica_cc__Funding__c = :activePlan.Id
                WITH USER_MODE
                GROUP BY maica_cc__Support_Category__c
        ];
        Map<String, Decimal> totalRemainingByCategoryId = new Map<String, Decimal>();
        for (AggregateResult totalVar : totals) {
            totalRemainingByCategoryId.put((String) totalVar.get('Support_Category__c'), (Decimal) totalVar.get('Remaining_Amount__c'));
        }

        this.response.put('totalRemainingByCategoryId', totalRemainingByCategoryId);
        this.response.put('activePlan', activePlan);
        this.response.put('hasActivePlan', activePlan != null);
        this.response.put('activePlanStartDateFormatted', activePlan?.maica_cc__Start_Date__c?.format());
        this.response.put('activePlanEndDateFormatted', activePlan?.maica_cc__End_Date__c?.format());
        this.response.put('isEnforceActivePlan', activePlan != null);
        this.response.put('budgetsByCategory', budgetsByCategory);
        this.response.put('colorSetting.start', 20);
        this.response.put('colorSetting.end', 80);
    }
}
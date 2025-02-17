//SECURED!
public with sharing class NDISProductManagGetAvailableItemsProc extends AbstractProcessor {

    private List<PricebookEntry> items;
    private final Integer limitVar = 10;

    public override Response process(Request request) {
        this.request = request;

        this.retrieveItems();

        return this.response;
    }

    private void retrieveItems() {
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(PricebookEntry.SObjectType);
        queryFactory.selectFields(('Id,' +
                'UnitPrice,' +
                'Product2Id,' +
                'Product2.Id,' +
                'Product2.Name,' +
                'Product2.QuantityUnitOfMeasure,' +
                'Product2.Bucket__c,' +
                'Product2.Support_Category__c,' +
                'Product2.Support_Category__r.Name,' +
                'Product2.Support_Category__r.maica_cc__Category_Number__c,' +
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c,' +
                'Product2.Support_Category__r.maica_cc__Short_Name__c,' +
                'Product2.Support_Item_Number__c,' +
                'Product2.Service_Day__c,' +
                'Product2.Service_Time__c,' +
                'Product2.Favourite__c').split(','));

        String supportCategoryId = this.request.getString('filter.supportCategoryId');
        String supportItemName = this.request.getString('filter.supportItemName');
        String pricebookId = this.request.getRequiredString('filter.pricebookId');
        String serviceDay = this.request.getRequiredString('filter.serviceDay');
        String serviceTime = this.request.getString('filter.serviceTime');
        String activePlanId = this.request.getString('filter.activePlanId');
        Boolean isEnforceActivePlan = this.request.getBoolean('filter.isEnforceActivePlan') == true && String.isNotBlank(activePlanId);
        Boolean isCategoryProduct = this.request.getBoolean('filter.isCategoryProduct') == true;

        List<String> conditions = new List<String>{
                'Pricebook2Id = :pricebookId',
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c != \'Subsidy\'',
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c != \'Supplement\'',
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c != \'Claimable Fee\'',
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c != \'Billable Fee\'',
                'Product2.Support_Category__r.maica_cc__Support_Purpose__c != \'Client Contribution\''
        };

        if (isCategoryProduct == true) {
            conditions.add('Product2.Bucket__c = true');
        } else {

            conditions.add('Product2.Bucket__c != true');

            if (String.isNotBlank(serviceDay)) {
                List<String> serviceDays = new List<String>{
                        null, serviceDay
                };
                conditions.add('Product2.Service_Day__c IN :serviceDays');
            }

            if (String.isNotBlank(serviceTime)) {
                List<String> serviceTimes = new List<String>{
                        null, serviceTime
                };
                conditions.add('Product2.Service_Time__c IN :serviceTimes');
            }

            if (String.isNotBlank(supportItemName)) {
                supportItemName = '%' + supportItemName + '%';
                conditions.add('(Product2.Name LIKE :supportItemName OR Product2.Support_Item_Number__c LIKE :supportItemName)');
            }
        }

        if (String.isNotBlank(supportCategoryId)) {
            conditions.add('Product2.Support_Category__c = :supportCategoryId');
        }

        Set<String> categoryIds = new Set<String>();
        Map<String, maica_cc__Funding_Item__c> budgetMap;
        Map<String, Decimal> remainingAmountBySupportCategory = new Map<String, Decimal>();

        if (isEnforceActivePlan == true) {
            List<maica_cc__Funding_Item__c> planBudgets = [
                    SELECT Id, Name, maica_cc__Support_Category__c, maica_cc__Support_Category__r.maica_cc__Support_Purpose__c, maica_cc__Support_Item__c
                    FROM maica_cc__Funding_Item__c
                    WHERE maica_cc__Funding__c = :activePlanId
                    WITH USER_MODE
            ];

            List<AggregateResult> coreRemainingResults = [
                    SELECT SUM(maica_cc__Remaining_Amount__c) Remaining_Amount__c
                    FROM maica_cc__Funding_Item__c
                    WHERE maica_cc__Funding__c = :activePlanId AND maica_cc__Support_Category__r.maica_cc__Support_Purpose__c = 'Core'
                    WITH USER_MODE
            ];
            Decimal coreRemainingAmount = Utils.objects.defaultIfNull((Decimal) coreRemainingResults[0].get('Remaining_Amount__c'), 0);
            Set<Id> coreSupportCategories;
            if (coreRemainingAmount > 0) {
                coreSupportCategories = Utils.sObjects.getIdFieldValues([
                        SELECT maica_cc__Support_Category__c
                        FROM maica_cc__Funding_Item__c
                        WHERE maica_cc__Funding__c = :activePlanId AND maica_cc__Support_Category__r.maica_cc__Support_Purpose__c = 'Core'
                        WITH USER_MODE
                ], maica_cc__Funding_Item__c.maica_cc__Support_Category__c);
            }

            List<AggregateResult> remainingAmountSummary = [
                    SELECT SUM(maica_cc__Remaining_Amount__c) Remaining_Amount__c, maica_cc__Support_Category__c Support_Category__c
                    FROM maica_cc__Funding_Item__c
                    WHERE maica_cc__Funding__c = :activePlanId
                    WITH USER_MODE
                    GROUP BY maica_cc__Support_Category__c
                    HAVING SUM(maica_cc__Remaining_Amount__c) > 0
            ];

            for (AggregateResult result : remainingAmountSummary) {
                Decimal remainingAmount = (Decimal) result.get('Remaining_Amount__c');
                String categoryId = (String) result.get('Support_Category__c');
                if (remainingAmount > 0) {
                    categoryIds.add(categoryId);
                }
                remainingAmountBySupportCategory.put(categoryId, remainingAmount);
            }

            budgetMap = new Map<String, maica_cc__Funding_Item__c>();
            for (maica_cc__Funding_Item__c budgetVar : planBudgets) {
                Decimal remainingAmount = Utils.objects.defaultIfNull(remainingAmountBySupportCategory?.get(budgetVar.maica_cc__Support_Category__c), 0);

                if (coreSupportCategories != null && coreSupportCategories.contains(budgetVar.maica_cc__Support_Category__c) && budgetMap.containsKey(budgetVar.maica_cc__Support_Category__c) != true) {

                    for (Id coreSupportCategoryId : coreSupportCategories) {
                        if (budgetMap.containsKey(coreSupportCategoryId) != true) {
                            budgetMap.put(coreSupportCategoryId + '-' + budgetVar.maica_cc__Support_Item__c, budgetVar);
                            budgetMap.put(coreSupportCategoryId, budgetVar);
                        }
                    }

                } else if (remainingAmount > 0) {
                    budgetMap.put(budgetVar.maica_cc__Support_Category__c + '-' + budgetVar.maica_cc__Support_Item__c, budgetVar);
                    budgetMap.put(budgetVar.maica_cc__Support_Category__c, budgetVar);
                }
            }

            conditions.add('Product2.Support_Category__c IN :categoryIds');
        }

        queryFactory.setCondition(String.join(conditions, ' AND '));
        queryFactory.getOrderings().clear();
        queryFactory.addOrdering('Product2.Favourite__c', fflib_QueryFactory.SortOrder.DESCENDING, true);
        if (isCategoryProduct == true) {
            queryFactory.addOrdering('Product2.Category_Number__c', fflib_QueryFactory.SortOrder.ASCENDING, true);
        }
        queryFactory.addOrdering('Product2.Name', fflib_QueryFactory.SortOrder.ASCENDING);

        queryFactory.setLimit(this.limitVar + 1);

        String SOQL = queryFactory.toSOQL();
        SOQL = SOQL.replace('Product2.QuantityUnitOfMeasure', 'toLabel(Product2.QuantityUnitOfMeasure)');

        this.items = Database.query(SOQL);
        this.response.getMapper().mapFromListSObjects(
                'items',
                this.items,
                budgetMap == null ? null : new AutoMapper.BinderQueue(new PlanBudgetBinder(budgetMap, remainingAmountBySupportCategory)),
                this.limitVar
        );
    }

    class PlanBudgetBinder implements AutoMapper.IBinder {

        private Map<String, maica_cc__Funding_Item__c> budgetMap;
        private Map<String, Decimal> remainingAmountBySupportCategory;

        PlanBudgetBinder(Map<String, maica_cc__Funding_Item__c> budgetMap, Map<String, Decimal> remainingAmountBySupportCategory) {
            this.budgetMap = budgetMap;
            this.remainingAmountBySupportCategory = remainingAmountBySupportCategory;
        }

        public void bind(SObject record, Map<String, Object> dataMap) {
            PricebookEntry entryVar = (PricebookEntry) record;
            maica_cc__Funding_Item__c budgetVar = budgetMap.get(entryVar.Product2.Support_Category__c + '-' + entryVar.Product2Id);
            if (budgetVar == null) {
                budgetVar = budgetMap.get(entryVar.Product2.Support_Category__c);
            }
            dataMap.put('budget', budgetVar);
            dataMap.put('supportCategoryRemaining', remainingAmountBySupportCategory?.get(entryVar.Product2.Support_Category__c));
        }
    }
}
//SECURED!
public with sharing class NDISProductManagementQASubmitProc extends AbstractProcessor {

    public override Response process(Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private List<DTO> items;

    private UnitOfWork uow = new UnitOfWork(
            new List<SObjectType>{
                    Opportunity.SObjectType,
                    PricebookEntry.SObjectType,
                    OpportunityLineItem.SObjectType
            }
    );

    private void doSubmit() {
        String opportunityId = this.request.getRequiredString('recordId');
        Opportunity opportunityVar = (Opportunity) Utils.arrays.firstOrException(
                [SELECT Id, Pricebook2Id, Funding__c FROM Opportunity WHERE Id = :opportunityId WITH USER_MODE],
                'No Opportunity with Id: ' + opportunityId
        );
        Utils.objects.throwIfBlank(opportunityVar.Pricebook2Id, 'Opportunity has no Pricebook assigned');

        this.items = this.request.getListAsDTO('items');

        Map<String, PricebookEntry> supportItemToPriceListEntry = new Map<String, PricebookEntry>();

        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (DTO itemDTO : items) {
            String itemId = itemDTO.getString('Id');
            itemDTO.put('Id', null);
            itemDTO.put('TotalPrice', null);
            itemDTO.put('Discount', null);
            OpportunityLineItem lineItem = new OpportunityLineItem();
            itemDTO.getMapper().mapToSObject(lineItem);
            lineItems.add(lineItem);
            supportItemToPriceListEntry.put(lineItem.Product2Id, null);
        }

        List<PricebookEntry> pricebookEntries = [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Product2Id IN :supportItemToPriceListEntry.keySet() AND Pricebook2Id = :opportunityVar.Pricebook2Id
                AND IsActive = TRUE
                AND Pricebook2.IsActive = TRUE
                WITH USER_MODE
        ];
        for (PricebookEntry pricebookEntryVar : pricebookEntries) {
            supportItemToPriceListEntry.put(pricebookEntryVar.Product2Id, pricebookEntryVar);
        }

        for (OpportunityLineItem lineItem : lineItems) {
            PricebookEntry entryVar = supportItemToPriceListEntry.get(lineItem.Product2Id);
            if (entryVar == null) {
                entryVar = new PricebookEntry(
                        Product2Id = lineItem.Product2Id,
                        Pricebook2Id = opportunityVar.Pricebook2Id,
                        UnitPrice = lineItem.UnitPrice,
                        IsActive = true
                );
                uow.registerNew(entryVar);
            }
            lineItem.OpportunityId = opportunityVar.Id;
            uow.registerNew(lineItem, OpportunityLineItem.PricebookEntryId, entryVar);
        }
        DMLManager.deleteAsUser([SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opportunityVar.Id WITH USER_MODE]);
        uow.commitWork();

        this.response.put('total', items.size());
    }

}
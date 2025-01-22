({
    setItem: function (cmp, oppLineItemVar){
        var item = cmp.get('v.item');
        item.maica_cc__Support_Item__c = oppLineItemVar.supportItemId;
        item.maica_cc__Support_Item__r = oppLineItemVar.supportItem;
        item.maica_cc__Quantity__c = oppLineItemVar.Quantity;
        item.maica_cc__Rate__c = oppLineItemVar.UnitPrice;
        item.oppLineItemId = oppLineItemVar.Id;
        cmp.set('v.item', item);
    }
});
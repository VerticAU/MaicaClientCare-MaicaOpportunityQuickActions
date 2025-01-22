({
    handleInit: function (cmp, event, helper) {
        $A.enqueueAction(cmp.get('c.handleItemChange'));
    },

    handleRemoveClick: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onRemove");
        completeEvent.setParams({
            "payload": {
                index: cmp.get('v.index'),
                oppLineItemId: cmp.get('v.item.oppLineItemId')
            }
        });
        completeEvent.fire();
    },

    handleItemChange: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onChange");
        completeEvent.setParams({"payload": {index: cmp.get('v.index')}});
        completeEvent.fire();
    },

    handleProductChange: function (cmp, event, helper) {
        if(event.getParams().index == 'oppLineItemId' && cmp.get('v.item.oppLineItemId') && !cmp.get('v.item.maica_cc__Support_Item__c')){
            var oppLineItemsMap = cmp.get('v.oppLineItemsMap');
            var oppLineItemVar = oppLineItemsMap[cmp.get('v.item.oppLineItemId')];

            helper.setItem(cmp, oppLineItemVar);

            var completeEvent = cmp.getEvent("onOppLineItemUpdate");
            completeEvent.setParams({
                "payload": {
                    oppLineItemId: cmp.get('v.item.oppLineItemId'),
                    needAddOppLineItemOption: false
                }
            });
            completeEvent.fire();
        }
    }
});
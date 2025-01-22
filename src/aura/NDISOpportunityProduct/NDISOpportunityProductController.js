({
    handleEditItemClick: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onEdit");
        completeEvent.setParams({
            "payload": {
                index: cmp.get('v.index'),
                item: cmp.get('v.item'),
            }
        });
        completeEvent.fire();
    },

    handleRemoveItemClick: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onRemove");
        completeEvent.setParams({"payload": {index: cmp.get('v.index')}});
        completeEvent.fire();
    },

    handleItemChange: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onChange");
        completeEvent.setParams({"payload": {index: cmp.get('v.index')}});
        completeEvent.fire();
    },
    handleDuplicateItemClick: function (cmp, event, helper) {
        var completeEvent = cmp.getEvent("onDuplicate");
        completeEvent.setParams({"payload": {item: JSON.parse(JSON.stringify(cmp.get('v.item')))}});
        completeEvent.fire();
    },

    updateLineTotal: function (cmp, event, helper) {
        var total = (cmp.get('v.item.Quantity') || 0) * (cmp.get('v.item.UnitPrice') || 0);
        cmp.set('v.item.TotalPrice', parseFloat(total.toFixed(2)));
    }

});
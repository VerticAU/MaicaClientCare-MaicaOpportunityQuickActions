({
    handleInit: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    },

    handleDependentChange: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    },

    handleValueChange: function(cmp, event, helper){
        var completeEvent = cmp.getEvent("onChange");
        completeEvent.setParams({
            payload: {
                name: event.getSource().get('v.name'),
                value: event.getSource().get('v.value'),
                oldValue: cmp.get('v.oldValue')
            }
        });
        completeEvent.fire();
    },

    handleValueChange2: function(cmp, event, helper){
        cmp.set('v.oldValue', event.getParam("oldValue"));
    }
})
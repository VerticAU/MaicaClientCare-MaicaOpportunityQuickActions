({
    handleConfirmClick: function (cmp, event, helper) {
        if (!cmp.find('modal').validate()) {
            return;
        }

        if(!helper.validateItems(cmp, event, helper)){
            cmp.find('modal').showErrors([
                'Please review the rows.'
            ], false);
            return;
        } else {
            cmp.find('modal').showErrors([], false);
        }

        cmp.set('v.hideContentOnBusy', false);

        helper.execute(
            cmp,
            'CreateServiceAgreementOnOppQASubmitProc',
            cmp.get('v.meta.dto'),
            function (response) {
                cmp.find('notifLib').showToast({
                    variant: 'success',
                    message: 'Service Agreement {0} was created',
                    messageData: [{
                        label: response.dto.serviceAgreement.Name,
                        url: '/' + response.dto.serviceAgreement.Id
                    }]
                });

                cmp.find('modal').close();
            },
            function (errors) {
                cmp.find('modal').find('errorMessages').showErrors(errors, true);
            }
        )
    },

    handleAddItemClick: function(cmp, event, helper){
        var items = cmp.get('v.meta.dto.agreementItems') || [];

        if((cmp.get('v.meta.selectOptions.oppLineItemsOptions') || []).length == 0){
            cmp.find('notifLib').showToast({
                variant: 'success',
                message: 'You don\'t have any Opportunity Products',
            });
            return;
        }

        items.push({});
        cmp.set('v.meta.dto.agreementItems', items);
    },

    handleRemoveItemClick: function(cmp, event, helper){
        var payload = event.getParam('payload');

        if(payload){
            var items = cmp.get('v.meta.dto.agreementItems') || [];
            items.splice(payload.index, 1);
            cmp.set('v.meta.dto.agreementItems', items);

            helper.refreshOppLineItemsOptions(cmp, payload.oppLineItemId, true);
        }
    },

    handleItemsChange: function(cmp, event, helper) {
        var items = cmp.get('v.meta.dto.agreementItems') || [];
        var total = items.reduce(function (total, item) {
            var t = 0;
            try{
                t = (item.maica_cc__Rate__c || 0) * (item.maica_cc__Quantity__c || 0);
            }catch (e){}
            return total + t;
        }, 0);
        cmp.set('v.meta.totals.grandTotal', total);

        helper.resetFlexibleLockedValidation(cmp);
    },

    handleOppLineItemUpdate: function (cmp, event, helper) {
        var payload = event.getParam('payload');

        if(payload){
            helper.refreshOppLineItemsOptions(cmp, payload.oppLineItemId, payload.needAddOppLineItemOption);
        }
    }
})
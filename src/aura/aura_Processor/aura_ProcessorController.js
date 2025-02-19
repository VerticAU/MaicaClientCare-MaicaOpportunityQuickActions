({
    handleInit: function (cmp, event, helper) {
        if (!cmp.get('v.stage')) {
            cmp.set('v.stage', 'initial');
        }
        cmp.set('v.meta.showMoreErrorDetails', false);
        var eventVar = cmp.getEvent('onInit')
        eventVar.setParams({
            payload: {}
        })
        eventVar.fire();
    },

    handleProcess: function (cmp, event, helper) {

        var errorMessages = cmp.find('errorMessages');
        if(errorMessages){
            errorMessages.clearErrors();
        }

        if(cmp.get('v.validateOnProcess') == true && errorMessages){
            var validationResult = helper.utils(cmp).validate(
                cmp.find('form'),
                {}
            );

            if (validationResult.allValid !== true) {
                cmp.find('errorMessages').showErrors(validationResult.getErrorMessages(), true);
                return Promise.reject(validationResult.getErrorMessages());
            }
        }

        cmp.set('v.stage', 'pending');
        cmp.set('v.response', null);

        return helper.execute(
            cmp,
            event.getParams().arguments.processor || cmp.get('v.processor'),
            event.getParams().arguments.request,
            function (response) {
                cmp.set('v.stage', 'success');
                cmp.set('v.response', response);
            },
            function (errors) {
                cmp.set('v.stage', 'failure');
                cmp.set('v.meta.errors', errors);
                cmp.set('v.meta.error', errors[0].message);
                cmp.set('v.response', {
                    dto: {
                        isValid: false,
                        errors: errors,
                        error: errors[0].message
                    }
                });
            }
        ).finally(function () {

        });
    },

    handleCloseClick: function (cmp, event, helper) {
        cmp.set('v.stage', 'initial');
        cmp.set('v.meta.showMoreErrorDetails', false);
    },

    handleShowMoreInformationErrorClick: function (cmp, event, helper) {
        if(cmp.get('v.meta.showMoreErrorDetails')){
            cmp.set('v.meta.showMoreErrorDetails', false);
        }else{
            cmp.set('v.meta.showMoreErrorDetails', true);
        }
    },

    handleSetStage: function (cmp, event, helper) {
        cmp.set('v.stage', event.getParams().arguments.stage);
    },
});
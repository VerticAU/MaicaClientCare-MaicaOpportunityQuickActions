({
    baseHandleInit: function (cmp, event, helper) {
        var promise = helper.doInit(
            cmp,
            cmp.get('v.processor'),
            {
                recordId: cmp.get('v.recordId')
            }
        );

        promise.catch(function (errors) {
            var closeAction = $A.get("e.force:closeQuickAction");
            if (closeAction) {

                closeAction.fire();

                helper.getBaseCmp(cmp).find('errorMessages').clearErrors();

                helper.getBaseCmp(cmp).utils.showToast(
                    {
                        message: errors && errors.length > 0 ? errors[0].message : 'Unknown error: ' + JSON.stringify(errors),
                        type: 'error'
                    }
                );
            }
        });

        return promise;
    },

    handleDoInit: function (cmp, event, helper) {
        var payload = event.getParam('arguments').payload || {};
        var processor = event.getParam('arguments').processor || cmp.get('v.processor');

        if (payload.recordId === undefined) {
            payload.recordId = cmp.get('v.recordId');
        }

        return helper.doInit(
            cmp,
            processor,
            payload
        );
    },

    handleValidate: function (cmp, event, helper) {
        var params = event.getParam('arguments') || {};
        return helper.validateForm(
            helper.getBaseCmp(cmp, 'c:aura_Base'),
            'form',
            params.options || {}
        );
    },

    handleShowErrors: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.getBaseCmp(cmp).find('errorMessages').showErrors(
                params.errors,
                params.isScrollTop === true
            );
        }

    },

    handleClearErrors: function (cmp, event, helper) {
        helper.getBaseCmp(cmp).find('errorMessages').clearErrors();

    }
})
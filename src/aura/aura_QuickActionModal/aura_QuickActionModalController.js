({

    handleInit: function (component, event, helper) {
        helper.calculateContentHeight(component)
    },

    handleHeightChange: function (component, event, helper) {
        helper.calculateContentHeight(component)
    },

    handleCancel: function (cmp, event, helper) {
        helper.cancel(cmp);
    },

    handleCloseQuickAction: function (cmp, event, helper) {
        if (cmp.get('v.isClosed') != true) {
            helper.cancel(cmp);
        }
    },

    handleSetScrollable: function (cmp, event, helper) {

        var bodyCmp = cmp.find('modal-body');

        var params = event.getParam('arguments');
        if (params) {
            var isScrollable = params.isScrollable;

            if(isScrollable == true){
                $A.util.removeClass(bodyCmp, "slds-scrollable_none");
            } else{
                $A.util.addClass(bodyCmp, "slds-scrollable_none");
            }
        }
    },

    handleScrollTop: function (cmp, event, helper) {
        var scroller = cmp.find('scrollerWrapper');
        if(scroller && scroller.getElement()){
            setTimeout(function () {
                scroller.getElement().scrollIntoView();
            })
        }
    },

    handleValidate: function(cmp, event, helper){
        var errorMessagesCmp = cmp.find('errorMessages');
        errorMessagesCmp.clearErrors();

        var params = event.getParam('arguments') || {};

        var validationResult = cmp.utils.validate(
            cmp,
            params.options || {}
        );

        if(validationResult.allValid !== true){
            errorMessagesCmp.showErrors(validationResult.getErrorMessages(), true);
            return false;
        }

        return true;
    },

    handleShowErrors: function(cmp, event, helper){
        var params = event.getParam('arguments');
        if (params) {
            cmp.find('errorMessages').showErrors(params.errors, params.isScrollTop === true);
        }

    }
})
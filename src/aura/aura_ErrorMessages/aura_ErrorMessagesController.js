({
    handleSetScrollable: function (cmp, event, helper) {

        var bodyCmp = cmp.find('container');

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
        helper.scrollTop(cmp);
    },

    handleShowErrors: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.showErrors(
                cmp,
                params.errors || [],
                params.isScrollTop === true
            );
        }
    },

    handleClearErrors: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.showErrors(
                cmp,
                [],
                false
            );
        }
    }
})
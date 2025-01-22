({
    calculateContentHeight: function (component) {
        if (component.get('v.heightPercentage') > 0) {
            component.set('v.contentHeight', 'calc(' + component.get('v.heightPercentage') + '% - 120px)')
        } else {
            component.set('v.contentHeight', (component.get('v.heightPX') - 120) + 'px')
        }
    },

    cancel: function (cmp) {
        cmp.set('v.isClosed', true);

        var closeAction = $A.get("e.force:closeQuickAction");
        if (closeAction) closeAction.fire();

        if (cmp.get('v.refreshOnCancel') === true) {
            var refreshAction = $A.get("e.force:refreshView");
            if (refreshAction) refreshAction.fire();
        }
    }
})
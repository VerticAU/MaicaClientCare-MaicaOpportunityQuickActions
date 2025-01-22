({
    handleInit: function(cmp, event, helper){
        cmp.set('v.overlayLib', cmp.find('overlayLib'));
    },

    handleCloseModal: function(cmp, event, helper){
        cmp.get('v.modalInstance').close(event.getParams().arguments.response);
        cmp.get('v.overlayLib').notifyClose();
    },

    handleCancelModal: function(cmp, event, helper){
        cmp.get('v.modalInstance').cancel(event.getParams().arguments.response);
        cmp.get('v.overlayLib').notifyClose();
    }

})
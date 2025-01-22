({
    handleShow: function (cmp, event, helper) {
        var componentName = event.getParam('arguments').componentName;
        var payload = event.getParam('arguments').payload || {};
        var modalAttributes = event.getParam('arguments').modalAttributes || {};

        cmp.set('v.isBusy', true);

        return new Promise($A.getCallback(function (resolve, reject) {
            $A.createComponent(
                componentName,
                payload,
                function (createdComponent, status, errorMessage) {
                    if (status === "SUCCESS") {

                        var modalInstance = {
                            close: $A.getCallback(function (result) {
                                resolve(result);
                            }),
                            cancel: $A.getCallback(function (result) {
                                reject(result);
                            })
                        };

                        createdComponent.set('v.modalInstance', modalInstance);
                        var footer = createdComponent.get('v.footer');
                        if ($A.util.isEmpty(footer) == false) {
                            modalAttributes.footer = footer;
                        }

                        modalAttributes.body = createdComponent;
                        modalAttributes.closeCallback = function () {
                            if (payload.closeCallback) {
                                payload.closeCallback(resolve, reject);
                            }
                        }

                        cmp.find('overlayLib').showCustomModal(modalAttributes).then($A.getCallback(function (overlay) {
                            cmp.set('v.isBusy', false);
                            if (payload.showCallback) {
                                payload.showCallback(resolve, reject);
                            }
                        }));

                    } else if (status === "INCOMPLETE") {
                        console.log("No response from the server!")
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        reject(errorMessage)
                    }
                }
            );
        }));
    },
})
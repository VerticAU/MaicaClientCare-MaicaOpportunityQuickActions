({
    handleRemoveItemClick: function (cmp, event, helper) {
        var payload = event.getParam('payload');
        if (payload) {
            var items = cmp.get('v.meta.dto.items') || [];
            items.splice(payload.index, 1);
            cmp.set('v.meta.dto.items', items);
        }
    },
    handleDuplicateItemClick: function (cmp, event, helper) {
        var payload = event.getParam('payload');
        if (payload) {
            var items = cmp.get('v.meta.dto.items') || [];
            delete payload.item.Id;
            delete payload.item.currentPeriod;
            items.push(payload.item);
            cmp.set('v.meta.dto.items', items);
        }
    },
    handleAddItemClick: function (cmp, event, helper) {
        cmp.find('modalService').show(
            'c:NDISProductManagementScheduleModal',
            {
                meta: cmp.get('v.meta')
            },
            {
                header: 'Add Funding'
            }
        ).then($A.getCallback(function (response) {
            if (response.items) {
                var items = cmp.get('v.meta.dto.items') || [];
                items = items.concat(response.items);
                cmp.set('v.meta.dto.items', items);
            }
        }, function (error) {

        }))
    },

    handleEditItemClick: function (cmp, event, helper) {
        var payload = event.getParam('payload');
        payload.item.type = payload.item.type || (payload.item.Product2.Category_Funding__c == true ? 'Category' : 'Item');
        cmp.find('modalService').show(
            'c:NDISProductManagementScheduleModal',
            {
                meta: cmp.get('v.meta'),
                item: payload.item,
                index: payload.index
            },
            {
                header: 'Add Funding',
                cssClass: 'slds-modal_medium'
            }
        ).then($A.getCallback(function (response) {
            if (response.item) {
                var items = cmp.get('v.meta.dto.items') || [];
                items[payload.index] = response.item;
                cmp.set('v.meta.dto.items', items);
            }
        }, function (error) {
            console.error(error);
        }))
    },

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
            'NDISProductManagementQASubmitProc',
            {
                recordId: cmp.get('v.recordId'),
                activePlanId: cmp.get('v.meta.dto.activePlan.Id'),
                items: cmp.get('v.meta.dto.items'),
            }
        ).then(function (response) {
            cmp.find('notifLib').showToast({
                variant: 'success',
                message: 'The Products have been updated.',
            });

            $A.get('e.force:refreshView').fire();
            cmp.find('modal').close();
        }).catch(function (errors) {
            cmp.find('modal').find('errorMessages').showErrors(errors, true);
        });
    },

    refreshTotals: function (cmp, event, helper) {
        try {
            if(cmp.get('v.meta.isValid') !== true){
                return;
            }
            var items = cmp.get('v.meta.dto.items') || [];
            var totalAmount = items.reduce((total, item) => {
                total += parseFloat(item.TotalPrice || 0);
                return total;
            }, 0);

            var summary = {
                totalItems: items.length,
                totalAmount: totalAmount,
                totalAmountFormatted: $A.localizationService.formatCurrency(totalAmount)
            };
            cmp.set('v.meta.summary', summary);

            $A.enqueueAction(cmp.get('c.refreshRemaining'));
            $A.enqueueAction(cmp.get('c.refreshPlanBudget'));
        }catch (e){

        }
    },

    refreshRemaining: function (cmp, event, helper) {
        if(cmp.get('v.meta.isValid') !== true){
            return;
        }
        var items = cmp.get('v.meta.dto.items') || [];
        var totalsByCategories = {};
        items.reduce(function (res, item) {
            var total = totalsByCategories[item.Product2.Support_Category__c] || 0;
            ;
            total += parseFloat(item.TotalPrice);
            totalsByCategories[item.Product2.Support_Category__c] = total;
            return totalsByCategories;
        }, {});

        var totalRemainingByCategoryId = cmp.get('v.meta.dto.totalRemainingByCategoryId') || {};

        var isEnforcePlan = cmp.get('v.meta.dto.hasActivePlan') == true;

        var isUpdated = false;

        items.forEach(item => {
            if (isEnforcePlan) {
                item.totalRemaining = totalRemainingByCategoryId[item.Product2.Support_Category__c] || 0;
                item.totalEntered = totalsByCategories[item.Product2.Support_Category__c] || 0;
                item.totalRemainingFormatted = $A.localizationService.formatCurrency(item.totalRemaining);

                var isExceedsCategoryRemaining = item.totalEntered > item.totalRemaining;
                isUpdated = isUpdated || isExceedsCategoryRemaining != item.isExceedsCategoryRemaining;

                item.isExceedsCategoryRemaining = isExceedsCategoryRemaining;

                var entered = parseFloat(item.TotalPrice);
                item.usageProgress = item.totalRemaining == 0 && entered != 0 ?
                    100 :
                    ((item.totalRemaining == 0 ? 0 : (entered / item.totalRemaining)) * 100).toFixed(0);

                let usageProgressColor = helper.getColorByProgress(cmp, item.usageProgress);
                isUpdated = isUpdated || usageProgressColor != item.usageProgressColor;

                item.usageProgressColor = usageProgressColor;
            }
        });

        if (isUpdated) {
            cmp.set('v.meta.dto.items', items);
        }
    },

    handleItemsChange: function (cmp, event, helper) {
        $A.enqueueAction(cmp.get('c.refreshPlanBudget'));
    },

    refreshPlanBudget: function (cmp, event, helper) {
        var items = cmp.get('v.meta.dto.items') || [];
        var budgetsByCategory = cmp.get('v.meta.dto.budgetsByCategory') || {};

        var totalsByCategory = {};
        items.forEach(i => totalsByCategory[i.Product2.Support_Category__c] = (totalsByCategory[i.Product2.Support_Category__c] || 0) + i.TotalPrice);

        var categories = items.map(i => i.Product2.Support_Category__r);

        var key = 'Id';
        var uniqueCategories = [...new Map(categories.map(item =>
            [item[key], item])).values()]

        let totalRemainingByCategoryId = cmp.get('v.meta.dto.totalRemainingByCategoryId') || {};

        uniqueCategories = uniqueCategories.map(cat => {
            var remaining = totalRemainingByCategoryId[cat.Id] || 0;
            cat.totalRemaining = remaining;
            cat.totalPrice = totalsByCategory[cat.Id] || 0;
            cat.progress = cat.totalRemaining == 0 && cat.totalPrice != 0 ?
                100 :
                ((cat.totalRemaining == 0 ? 0 : (cat.totalPrice / cat.totalRemaining)) * 100).toFixed(0);
            // cat.threshold = cat.progress < 80 ?
            //     'success' :
            //     cat.progress >= 80 && cat.progress <= 100 ?
            //         'warning' : 'error';
            cat.progressColor = helper.getColorByProgress(cmp, cat.progress);

            cat.planBudgets = budgetsByCategory[cat.Id] || [];

            return cat;
        });

        cmp.set('v.meta.categories', uniqueCategories);
    },

    handlePlanBudgetSettingChange: function (cmp, event, helper) {
        if (event.getParams().index == 'start' || event.getParams().index == 'end') {
            $A.enqueueAction(cmp.get('c.refreshPlanBudget'));
            $A.enqueueAction(cmp.get('c.refreshRemaining'));
        }
    }

});
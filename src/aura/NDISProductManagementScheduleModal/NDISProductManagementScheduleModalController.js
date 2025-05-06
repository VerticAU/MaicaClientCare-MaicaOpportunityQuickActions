({
    handleInit: function (cmp, event, helper) {
        var item = cmp.get('v.item') || {
            type: 'Item'
        };

        if (!item.Period_Type__c) {
            item.Period_Type__c = cmp.get('v.meta.selectOptions.periodTypeOptions').some(o => o.value == 'Plan') ?
                'Plan' :
                cmp.get('v.meta.selectOptions.periodTypeOptions').some(o => o.value == 'Agreement') ? 'Agreement' : 'Custom';
        }
        if (!item.Service_Duration__c) {
            item.Service_Duration__c = 1;
        }
        if (!item.Service_Time__c) {
            item.Service_Time__c = 'Anytime';
        }
        if (!item.Schedule_Count__c) {
            item.Schedule_Count__c = 1;
        }
        if (!item.Service_Frequency__c) {
            item.Service_Frequency__c = 'One';
        }
        if (!item.Service_Day__c) {
            item.Service_Day__c = 'Weekday';
        }

        $A.enqueueAction(cmp.get('c.handlePeriodChange'));
        cmp.set('v.item', item);
        $A.enqueueAction(cmp.get('c.handleScheduleChange'));
    },

    handleRadioClick: function (cmp, event, helper) {
        var itemIndex = event.getSource().get('v.value');
        var records = cmp.get('v.meta.availableItemsResponse.dto.items.records');
        var item = cmp.get('v.item');
        var selectedEntry = records[itemIndex];

        cmp.set('v.item.PricebookEntryId', selectedEntry.Id);
        cmp.set('v.item.Product2Id', selectedEntry.Product2Id);
        cmp.set('v.item.Product2', selectedEntry.Product2);
        cmp.set('v.item.UnitPrice', selectedEntry.UnitPrice);
        cmp.set('v.item.TotalPrice', (selectedEntry.UnitPrice || 0) * (item.Quantity || 0));

        $A.enqueueAction(cmp.get('c.handleScheduleChange'));
    },

    handleCancelClick: function (cmp, event, helper) {
        cmp.cancelModal(false);
    },

    handleAddClick: function (cmp, event, helper) {
        if (!cmp.validate()) {
            return;
        }

        var selectedEntries = (cmp.get('v.meta.availableItemsResponse.dto.items.records') || []).filter(item => item.isSelected == true);

        if (!cmp.get('v.item.Quantity')) {
            cmp.find('notifLib').showToast({
                variant: 'warning',
                message: 'The Quantity can\'t be blank'
            });
            return;
        }

        if (!selectedEntries.length) {
            cmp.find('notifLib').showToast({
                variant: 'warning',
                message: 'No Support Item(s) selected to add'
            });
            return;
        }

        var sourceItem = cmp.get('v.item');

        cmp.closeModal({
            items: selectedEntries.map(function (selectedEntry) {
                var item = Object.assign({}, sourceItem);
                let isCategoryItem = item.type == 'Category';
                item.Start_Date__c = sourceItem.Start_Date__c;
                item.End_Date__c = sourceItem.End_Date__c;
                item.Service_Frequency__c = isCategoryItem ? null : sourceItem.Service_Frequency__c;
                item.Schedule_Count__c = isCategoryItem ? null : sourceItem.Schedule_Count__c;
                item.Schedule_Day__c = isCategoryItem ? null : sourceItem.Schedule_Day__c;
                item.Service_Day__c = isCategoryItem ? null : sourceItem.Service_Day__c;
                item.Service_Time__c = isCategoryItem ? null : sourceItem.Service_Time__c;
                item.Quantity = isCategoryItem ? 1 : sourceItem.Quantity;
                // item.Allow_Support_Item_Change__c = true;
                // item.Price_List_Entry__c = selectedEntry.Id;
                item.Product2Id = selectedEntry.Product2Id;
                item.Product2 = selectedEntry.Product2;
                item.UnitPrice = isCategoryItem ? item.UnitPrice : selectedEntry.UnitPrice;
                item.TotalPrice = (item.UnitPrice || 0) * (item.Quantity || 0);
                return item;
            }),
        });
    },


    handleSaveClick: function (cmp, event, helper) {
        if (!cmp.validate()) {
            return;
        }

        cmp.set('v.meta.quantityCalcResponse.showError', false);

        if (cmp.get('v.meta.quantityCalcResponse.dto.isItemValidForServiceDate') != true) {
            cmp.set('v.meta.quantityCalcResponse.showError', true);
            return;
        }

        if (!cmp.get('v.item.Quantity')) {
            cmp.find('notifLib').showToast({
                variant: 'warning',
                message: 'The Quantity can\'t be blank'
            });
            return;
        }

        cmp.closeModal({
            item: cmp.get('v.item')
        });
    },

    handleServiceDayChange: function (cmp, event, helper) {
        if (!event.getParams().index == 'Service_Day__c') {
            return;
        }

        var item = cmp.get('v.item');

        if (item.Service_Day__c == 'Public Holiday') {
            cmp.set('v.item.Service_Frequency__c', null);
        } else if (item.Service_Day__c != 'Public Holiday' && item.Service_Frequency__c == null) {
            cmp.set('v.item.Service_Frequency__c', 'One');
        } else if (item.Service_Day__c == 'Saturday') {
            cmp.set('v.item.Schedule_Day__c', 'Saturday');
        } else if (item.Service_Day__c == 'Sunday') {
            cmp.set('v.item.Schedule_Day__c', 'Sunday');
        } else if ((item.Service_Day__c == 'Weekday')) {
            cmp.set('v.item.Schedule_Day__c', 'Monday');
        } else if ((item.Service_Day__c == 'Anytime')) {
            cmp.set('v.item.Schedule_Day__c', null);
        }

        $A.enqueueAction(cmp.get('c.handleFilterChange'));
    },

    handleServiceFrequencyChange: function (cmp, event, helper) {
        if (event.getParams().index == 'Service_Frequency__c') {
            $A.enqueueAction(cmp.get('c.handleScheduleChange'));
        }
    },

    handleScheduleDayChange: function (cmp, event, helper) {
        if (event.getParams().index == 'Schedule_Day__c') {
            $A.enqueueAction(cmp.get('c.handleScheduleChange'));
        }
    },

    handleServiceTimeChange: function (cmp, event, helper) {
        if (event.getParams().index == 'Service_Time__c' && cmp.get('v.index') != undefined) {
            $A.enqueueAction(cmp.get('c.handleScheduleChange'));
        }
    },

    handleFilterChange: function (cmp, event, helper) {
        var filter = cmp.get('v.filter');
        filter.serviceDay = cmp.get('v.item.Service_Day__c');
        filter.serviceTime = cmp.get('v.item.Service_Time__c');
        filter.pricebookId = cmp.get('v.meta.dto.opportunity.Pricebook2Id');
        filter.isEnforceActivePlan = cmp.get('v.meta.dto.isEnforceActivePlan'); // ??? maybe needs to be a field on OppLineItem
        filter.activePlanId = cmp.get('v.meta.dto.activePlan.Id');
        filter.isCategoryProduct = cmp.get('v.item.type') === 'Category';

        var proc = cmp.find('availableItemProcessor');
        if (proc) {
            proc.process(
                'NDISProductManagGetAvailableItemsProc',
                {
                    filter: filter
                }
            ).then(function (response) {

            }).catch(function (errors) {
            });
        }
    },

    handleScheduleChange: function (cmp, event, helper) {
        var item = cmp.get('v.item');
        var proc = cmp.find('quantityCalcProcessor');
        if (proc) {
            proc.process(
                'NDISProductManagementCalcProc',
                {
                    opportunityId: cmp.get('v.meta.dto.opportunity.Id'),
                    enforceHolidaysByState: cmp.get('v.enforceHolidaysByState'),
                    item: item
                }
            ).then(function (response) {
                cmp.set('v.item.Quantity', response.dto.quantity);
            }).catch(function (errors) {
            });
        }
    },

    handlePeriodChange: function (cmp, event, helper) {
        var value = cmp.get('v.item.Period_Type__c');

        if (value == 'Plan') {
            cmp.set('v.item.Start_Date__c', cmp.get('v.meta.dto.activePlan.maica_cc__Start_Date__c'));
            cmp.set('v.item.End_Date__c', cmp.get('v.meta.dto.activePlan.maica_cc__End_Date__c'));

        } else if (value == 'Agreement') {
            cmp.set('v.item.Start_Date__c', cmp.get('v.meta.dto.opportunity.Agreement_Start_Date__c'));
            cmp.set('v.item.End_Date__c', cmp.get('v.meta.dto.opportunity.Agreement_End_Date__c'));
        } else {
            if(!cmp.get('v.item.Start_Date__c')){
                cmp.set('v.item.Start_Date__c', $A.localizationService.formatDate(new Date(), 'yyyy-MM-dd'));
            }
            if(!cmp.get('v.item.End_Date__c')){
                cmp.set('v.item.End_Date__c', $A.localizationService.formatDate(new Date(), 'yyyy-MM-dd'));
            }
        }
    },

    handleItemTypeChange: function(cmp, event, helper){
        var itemType = cmp.get('v.item.type');
        let isCategory = 'Category' == itemType;
        if(isCategory){
            cmp.set('v.item.Quantity', 1)
            cmp.set('v.item.Service_Duration__c', 1)
        }
        $A.enqueueAction(cmp.get('c.handleFilterChange'));
    }
})
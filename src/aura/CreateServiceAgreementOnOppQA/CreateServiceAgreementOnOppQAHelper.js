({
    refreshOppLineItemsOptions: function (cmp, oppLineItemId, needAddOppLineItemOption){
        if(!oppLineItemId){
            return;
        }

        var oppLineItemsMap = cmp.get('v.meta.dto.oppLineItemsMap') || [];
        var oppLineItemsOptions = cmp.get('v.meta.selectOptions.oppLineItemsOptions') || [];

        if(needAddOppLineItemOption){
            var oppLineItemVar = oppLineItemsMap[oppLineItemId];
            oppLineItemsOptions.unshift({value: oppLineItemVar.Id, label: oppLineItemVar.Product2.Name + ' ($' + oppLineItemVar.UnitPrice + ' Sales Price)'});
        }else{
            var indexToRemove = oppLineItemsOptions.findIndex(oppLineItemOption => oppLineItemOption.value == oppLineItemId);
            oppLineItemsOptions.splice(indexToRemove, 1);
        }

        cmp.set('v.meta.selectOptions.oppLineItemsOptions', oppLineItemsOptions);
    },

    validateItems: function(cmp, event, helper){
        let items = cmp.get('v.meta.dto.agreementItems') || [];

        let flexibleItems = items.filter(item => {
            return item.maica_cc__Allow_Support_Item_Change__c === true;
        });

        let lockedItems = items.filter(item => {
            return item.maica_cc__Allow_Support_Item_Change__c !== true;
        });

        let isCombinationFunding = cmp.get('v.meta.dto.isCombinationFunding') == true;

        let categoryGroupKey = (item) => {
            return (isCombinationFunding ? item.maica_cc__Funding_Type__c + ':' : '') + item.selectedCategoryId
        }
        let itemGroupKey = (item) => {
            return (isCombinationFunding ? item.maica_cc__Funding_Type__c + ':' : '') + item.maica_cc__Support_Item__c
        }

        let flexibleCounts = helper.groupCount(flexibleItems, categoryGroupKey);
        let lockedCounts = helper.groupCount(lockedItems, itemGroupKey);


        let rows = cmp.find('itemCmp');
        if (!Array.isArray(rows)) {
            rows = [rows];
        }

        let allRowsAreValid = rows.filter(row => {

            let item = row.get('v.item');
            let isFlexible = item.maica_cc__Allow_Support_Item_Change__c === true;
            let isDuplicateFlexibleCategory = isFlexible && flexibleCounts[categoryGroupKey(item)] > 1;
            row.set('v.isDuplicateFlexibleCategory', isDuplicateFlexibleCategory);

            let isDuplicateLockedProduct = isFlexible == false && lockedCounts[itemGroupKey(item)] > 1;
            row.set('v.isDuplicateLockedProduct', isDuplicateLockedProduct);

            return row.get('v.isDuplicateFlexibleCategory') || row.get('v.isDuplicateLockedProduct');

        }).length === 0;

        return allRowsAreValid;
    },

    groupCount: function (items, getNameFnc){
        var counts = items.reduce((summary, item) => {
            var name = getNameFnc(item);
            if (!summary.hasOwnProperty(name)) {
                summary[name] = 0;
            }
            summary[name]++;
            return summary;
        }, {});

        return counts;
    },

    resetFlexibleLockedValidation: function (cmp){
        let rows = cmp.find('itemCmp');
        if (!Array.isArray(rows)) {
            rows = [rows];
        }

        rows.forEach(row => {
            if(row.get('v.isDuplicateFlexibleCategory') == true){
                row.set('v.isDuplicateFlexibleCategory', false);
            }
            if(row.get('v.isDuplicateLockedProduct') == true){
                row.set('v.isDuplicateLockedProduct', false);
            }
        });
    }
});
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
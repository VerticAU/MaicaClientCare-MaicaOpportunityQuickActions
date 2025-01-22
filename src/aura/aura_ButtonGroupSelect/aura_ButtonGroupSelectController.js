({
    handleInit: function (cmp, event, helper) {
        if(!cmp.find('btn')){
            setTimeout(function () {
                $A.enqueueAction(cmp.get('c.handleInit'));
            });
        }else{
            $A.enqueueAction(cmp.get('c.refresh'));
        }
    },

    handleButtonClick: function (cmp, event, helper) {

        if(cmp.get('v.mode') == 'single'){
            cmp.set('v.value', event.getSource().get('v.value'));
            return;
        }

        var value = cmp.get('v.value') || '';
        var values = value ? value.split(';') : [];

        var buttonValue = event.getSource().get('v.value');

        if (values.indexOf(buttonValue) == -1) {
            values.push(buttonValue);
        } else {
            values.splice(values.indexOf(buttonValue), 1);
        }

        cmp.set('v.value', values.join(';'));

        // $A.enqueueAction(cmp.get('c.refresh'));
    },

    refresh: function (cmp, event, helper) {
        var value = cmp.get('v.value') || '';
        var values = value ? value.split(';') : [];

        //var buttons = cmp.find({instancesOf: 'lightning:button'}) || [];
        var buttons = cmp.find('btn') || [];
        if (!$A.util.isArray(buttons)) {
            buttons = [buttons];
        }
        buttons.forEach(button => {
            var isSelected = values.indexOf(button.get('v.value')) != -1;
            button.set('v.variant', isSelected ? cmp.get('v.variantActive') : cmp.get('v.variantInactive'));
        });
    }
});
({
    getColorByProgress: function(cmp, progress){
        var middleStart = cmp.get('v.meta.dto.colorSetting.start') || 20;
        var middleEnd = cmp.get('v.meta.dto.colorSetting.end') || 80;

        var color = 'rgb(24, 24, 24)';
        if(progress >= middleEnd){
            color = 'red';
        } else if(progress >= middleStart){
            color = 'orange';
        } else {
            color = 'green';
        }
        return color;
    },

    validateItems: function(cmp, event, helper){
        return true;
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
    }
});
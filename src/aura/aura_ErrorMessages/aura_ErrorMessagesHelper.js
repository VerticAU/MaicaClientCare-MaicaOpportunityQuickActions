({
    scrollTop: function (cmp) {
        var scroller = cmp.find('container');
        if(scroller && scroller.getElement()){
            setTimeout(function () {
                scroller.getElement().scrollIntoView();
            })
        }
    },

    showErrors: function (cmp, errors, isScrollTop) {
        cmp.set('v.errors', errors || []);
        if(isScrollTop === true){
            this.scrollTop(cmp);
        }
    }
})
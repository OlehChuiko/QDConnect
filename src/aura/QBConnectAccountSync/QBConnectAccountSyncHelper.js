({
    redirectToRecordPage : function(component,event, helper,RecordId) {
        var context = component.get("v.UserContext");
        if(context != undefined) {
            if(context == 'Theme4t' || context == 'Theme4d') {
                console.log('VF in S1 or LEX');
                sforce.one.navigateToSObject(RecordId);
            }else if(sforce.console.isInConsole()) {
                console.log('VF in console');
                window.location.assign('/'+RecordId+'?isdtp=vw');
            } else {
                console.log('VF in Classic'); 
                window.location.assign('/'+RecordId);
            }
        } else {
            console.log('standalone Lightning Component');
            var event = $A.get("e.force:navigateToSObject");
            event.setParams({"recordId": RecordId});
            event.fire();
        }
        
    },
	showSuccessMessage : function(component,event, helper,SuccessMessage) {
        component.set("v.SuccessMessage",SuccessMessage);
        $A.util.removeClass(component.find("SuccessMessage"), "toggle");
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("SuccessMessage"), "toggle");
            }), 5000
        );
    },
    showErrorMessage : function(component,event, helper,ErrorMessage) {
        component.set("v.ErrorMessage",ErrorMessage);
        $A.util.removeClass(component.find("ErrorMessage"), "toggle");
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("ErrorMessage"), "toggle");
            }), 5000
        );
    },
    clearAllMessages : function(component,event, helper,SuccessMessage) {
        component.set("v.SuccessMessage",'');
        component.set("v.ErrorMessage",'');
        $A.util.addClass(component.find("SuccessMessage"), "toggle");
        $A.util.addClass(component.find("ErrorMessage"), "toggle");
    },
})
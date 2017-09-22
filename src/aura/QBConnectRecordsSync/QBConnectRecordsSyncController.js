({
    doInit : function(component, event, helper) {
        //alert(component.get("v.recordId"));
        if(component.get("v.recordId")!=null && component.get("v.recordId")!=''){
            var action = component.get("c.syncRecordsToQB");
            action.setParams({
                RecordId : component.get("v.recordId"),
                sobjectName : component.get("v.sobjectName")
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS" && response.getReturnValue().success ) {
                    helper.showSuccessMessage(component,event, helper,response.getReturnValue().errorMessage);
                }else if(response.getState() === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            helper.showErrorMessage(component,event, helper,"Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                        helper.showErrorMessage(component,event, helper,"Unknown error");                                                         
                    }
                    
                }else if (!response.getReturnValue().success) {
                    helper.showErrorMessage(component,event, helper,response.getReturnValue().errorMessage);
                }
            });
            
            $A.enqueueAction(action);
        }else{
            helper.showErrorMessage(component,event, helper,"Invalid record id.");
        }
    },
    showSpinner : function (component, event, helper) {
        //Show modal and loading spinner
        $A.util.addClass(component.find("LoadingModal"), "slds-fade-in-open");
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
        
    },
    hideSpinner : function (component, event, helper) {
        //Show modal and loading spinner
        $A.util.removeClass(component.find("LoadingModal"), "slds-fade-in-open");
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();  
        
    },
    navigateToTecord : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        helper.redirectToRecordPage(component,event, helper,component.get("v.recordId"));
    },
})
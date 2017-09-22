({
    RefreshFieldWrapperData : function(component, event, helper) {
        if(component.get("v.selectedObject")!=''){
            var action = component.get("c.getCustomFieldNames");
            action.setParams({
                selectedObject : component.get("v.selectedObject"),
                ObjectToMap : null
            });
            action.setCallback(this, function(response) {
                if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                    component.set("v.fieldsWrapperList",JSON.parse(response.getReturnValue()).CustomField);
                    
                    //Select fields in select list from map
                    var myMap = component.get("v.SelectedObjAndFields");
                    var SelectOptionListJson=myMap[component.get("v.selectedObject")];
                    component.set("v.fieldsList",SelectOptionListJson);
                    
                }else if(response.getState() === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            helper.showErrorOnPage(component,event, helper,'ErrorDisplayId1',"Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                        helper.showErrorOnPage(component,event, helper,'ErrorDisplayId1',"Unknown error");                                                         
                    }
                    
                }else if (!JSON.parse(response.getReturnValue()).success) {
                    helper.showErrorOnPage(component,event, helper,'ErrorDisplayId1',JSON.parse(response.getReturnValue()).errorMessage);
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    showErrorOnPage : function(component,event, helper,displayDivId,ErrorMessage) {
        $A.createComponents([
            ["ui:message",{
                "title" : "Error",
                "severity" : "error",
            }],
            ["ui:outputText",{
                "value" : ErrorMessage
            }]
        ],
                            function(components, status, errorMessage){
                                if (status === "SUCCESS") {
                                    var message = components[0];
                                    var outputText = components[1];
                                    // set the body of the ui:message to be the ui:outputText
                                    message.set("v.body", outputText);
                                    var ErrorDisplayId = component.find(displayDivId);
                                    // Replace div body with the dynamic component
                                    ErrorDisplayId.set("v.body", message);
                                    
                                    window.setTimeout(
                                        $A.getCallback(function() {
                                            ErrorDisplayId.set("v.body", null);
                                        }), 10000
                                    );
                                }
                                else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.")
                                    // Show offline error
                                }
                                    else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                        // Show error message
                                    }
                            }
                           );
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
    clearAllMessages : function(component,event, helper,SuccessMessage) {
        $A.util.addClass(component.find("SuccessMessage"), "toggle");
        component.find('ErrorDisplayId1').set("v.body", null);
    },
    getAllSfFields : function(component, event, helper) {
        
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.fetchAllSfFields");
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.SelectedObjAndFields",response.getReturnValue());
            }else if(response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showErrorOnPage(component,event, helper,'ErrorDisplayId1',"Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showErrorOnPage(component,event, helper,'ErrorDisplayId1',"Unknown error");                                                         
                }
                
            }
        });
        
        $A.enqueueAction(action);
        
    },
    redirectToURL : function(component,event, helper,redirectURL) {
        var context = component.get("v.UserContext");
        if(context != undefined) {
            if(context == 'Theme4t' || context == 'Theme4d') {
                console.log('VF in S1 or LEX');
                sforce.one.navigateToURL(redirectURL);
            }else{
                console.log('VF in Classic'); 
                window.location.assign(redirectURL);
            }
        }else {
            console.log('standalone Lightning Component');
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": redirectURL,
                "isredirect" : true
            });
            urlEvent.fire();
        }
    }
})
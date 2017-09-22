({
    doInit : function(component, event, helper) {
        var authStep=component.get("v.authStep");
        var action = component.get("c.InitMethod");
        action.setParams({
            authStep : authStep,
            tokenParm : component.get("v.tokenParm"),
            tokenVerifier : component.get("v.tokenVerifier"),
            realmId : component.get("v.realmId")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                if(authStep=='2'){
                    //Redirect To QB Connect AUTH. Page
                    helper.redirectToURL(component,event, helper,'/apex/QB_Connect_Admin?authStep=3'); 
                }else if(authStep=='3'){
                    helper.showSuccessMessage(component,event, helper,'Success!  Your account is now connected to QuickBooks.');
                    helper.redirectToURL(component,event, helper,'/apex/QB_Connect_Admin');
                }else{
                    component.set("v.IsQBConnected",JSON.parse(response.getReturnValue()).IsQBConnected);
                    component.set("v.isPollBatchEnabled",JSON.parse(response.getReturnValue()).isPollBatchEnabled);
                    component.set("v.currencyDetails",JSON.parse(response.getReturnValue()).currencyDetails);
                    component.set("v.multiCurrencyDetails",JSON.parse(response.getReturnValue()).multiCurrencyDetails);
                    component.set("v.AutoRunInterval",JSON.parse(response.getReturnValue()).AutoRunInterval);
                    component.set("v.SyncAllQbToSf",JSON.parse(response.getReturnValue()).SyncAllQbToSf);
                    component.set("v.SyncAllSfToQb",JSON.parse(response.getReturnValue()).SyncAllSfToQb);
                }
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
    },
    ConnectToQuickBooks : function(component, event, helper) {
        var action = component.get("c.OAuth_Step1_getTempTokenAndRedirectToIntuit");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                //Redirect To QB Connect AUTH. Page
                helper.redirectToURL(component,event, helper,"https://appcenter.intuit.com/Connect/Begin?oauth_token="+JSON.parse(response.getReturnValue()).authToken);           
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
    },
    DisconnectQuickBooks : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.disconnectQB");
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Quickbooks account disconnected.');
                component.set("v.IsQBConnected",false);
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
    },
    refreshCurrency : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.refreshCurrencyDetails");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                component.set("v.currencyDetails",JSON.parse(response.getReturnValue()).currencyDetails);
                component.set("v.multiCurrencyDetails",JSON.parse(response.getReturnValue()).multiCurrencyDetails);
                helper.showSuccessMessage(component,event, helper,'Currency details refreshed successfully.');           
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
    },
    startScheduler : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.startSchedulers");
        action.setParams({
            AutoRunInterval : component.get("v.AutoRunInterval")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Job scheduled successfully.');
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
    },
    syncAllDataToQB : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.syncAllDataSFToQB");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Jobs submitted successfully. Synchronization may take few minutes.');
                component.set("v.isPollBatchEnabled",true); 
                component.set("v.SyncAllSfToQb",'(In Progress)');
                
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
    },
    syncAllDataToSF : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.syncAllDataQBToSF");
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Jobs submitted successfully. Synchronization may take few minutes.');
                component.set("v.isPollBatchEnabled",true);
                component.set("v.SyncAllQbToSf",'(In Progress)');                
                
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
    },
    onSelectedObjChange : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        helper.RefreshFieldWrapperData(component,event, helper);
    },
    refreshFieldsFromQB : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        component.set("v.MappingButtonsDisabled",false);
        var action = component.get("c.refreshFromQB");
        action.setParams({
            selectedObject : component.get("v.selectedObject")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Fields refreshed successfully.');
                component.set("v.fieldsWrapperList",JSON.parse(response.getReturnValue()).CustomField);
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
    EditMapping : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        component.set("v.MappingButtonsDisabled",false);
    },
    SaveFieldMapping : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        component.set("v.MappingButtonsDisabled",true);
        
        //Save Mapping here
        var action = component.get("c.SaveMapping");
        action.setParams({
            selectedObject : component.get("v.selectedObject"),
            fieldsWrapperListJSON : JSON.stringify(component.get("v.fieldsWrapperList"))
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                helper.showSuccessMessage(component,event, helper,'Field(s) mapping saved successfully.');
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
    },
    refreshBatchRun : function(component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        var action = component.get("c.pollBatchRunStatus");
        action.setParams({
            SyncAllQbToSf : component.get("v.SyncAllQbToSf"),
            SyncAllSfToQb : component.get("v.SyncAllSfToQb")
        });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS" && JSON.parse(response.getReturnValue()).success ) {
                component.set("v.isPollBatchEnabled",JSON.parse(response.getReturnValue()).isPollBatchEnabled);
                component.set("v.SyncAllQbToSf",JSON.parse(response.getReturnValue()).SyncAllQbToSf);
                component.set("v.SyncAllSfToQb",JSON.parse(response.getReturnValue()).SyncAllSfToQb);
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
    },
    CancelSaveMapping : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        helper.RefreshFieldWrapperData(component,event, helper);
        component.set("v.MappingButtonsDisabled",true);
    },
    navigateToAdminSetUp : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        component.set("v.IsPage1",true);
    },
    navigateToHome : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        //window.history.back();
        window.location.assign('/home/home.jsp');
    },
    navigateToFieldMapping : function (component, event, helper) {
        helper.clearAllMessages(component,event, helper);
        component.set("v.IsPage1",false);
        component.set("v.selectedObject",'');
        helper.getAllSfFields(component,event, helper);
    }
    
})
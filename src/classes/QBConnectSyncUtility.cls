//For all classes wrapper
 global with sharing class QBConnectSyncUtility{
    public static  Boolean isAccountManualSync=false;
    public static  Boolean isOppManualSync=false;
    public static  Boolean isQuoteManualSync=false;
    public static  Boolean isInvoiceManualSync=false;
    public static  Boolean isProductManualSync=false;
    public static  Boolean isTermManualSync=false;
    
    public static QuickBookAuthDetails1__c serviceObject; 
     
     @AuraEnabled
    global static RemoteSaveResult  syncRecordsToQB(id RecordId,String sobjectName){
        RemoteSaveResult wrap=new RemoteSaveResult();
        
        serviceObject = QuickbooksUtility.getServiceSettings();
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
            wrap.success=false;
            wrap.errorMessage='You are not connected to a QuickBooks Account.';
            return wrap;
        }
        
        if(sobjectName.equalsIgnoreCase('Account')){
            wrap= syncAccount(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('Opportunity')){
            wrap= syncOpp(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('Quote')){
            wrap= syncQuote(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('Invoice')){
            wrap= syncInvoice(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('Product2')){
            wrap= syncProduct(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('Term')){
            wrap= syncTerm(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('PaymentFetch')){
            wrap= readAllPayments(string.valueOf(RecordId));
        }else if(sobjectName.equalsIgnoreCase('InvoiceFetch')){
            wrap= readAllInvoices(string.valueOf(RecordId));
        }
        return wrap;
    }
    public static RemoteSaveResult  syncAccount(string AccId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isAccountManualSync=true;
            String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery,False)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True))
            {
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            Account acc=MapAccountToQuickBookController.createAccountQB(AccId);
            if(acc!=Null && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update acc;
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    
    //Opp Sync
    public static  RemoteSaveResult  syncOpp(string oppId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isOppManualSync=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
            {       
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            Opportunity opp=MapOpportunityToQuickBookController.createOppQB(oppId);
            if(opp!=Null  && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update opp;
                if(!MapOpportunityToQuickBookController.isAccountUpdatedMap.isEmpty()){
                    update MapOpportunityToQuickBookController.isAccountUpdatedMap.values();
                }
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
        }catch(Exception e){
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
        }
        return wrap;
    }
    //QuoteSync Sync
    public static  RemoteSaveResult  syncQuote(string quoteId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isQuoteManualSync=true;
            String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c','QB_Balance__c','EstimateNumber__c'};
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
            if(!QuickbooksUtility.CheckFieldPermission('quote','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('quote','isUpdateable',FieldsToQuery,false) 
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
            {       
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            quote quoteObj=MapInvoiceToQuickBookController.createInvoiceQB(quoteId);
            if(quoteObj!=Null && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update quoteObj;
                
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
            if(!MapInvoiceToQuickBookController.prodList.isEmpty()){
                update MapInvoiceToQuickBookController.prodList.values();
            }
            if(serviceObject!=Null){
                if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount))
                    serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount))
                    serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                
                update serviceObject;
            }
            if(!MapInvoiceToQuickBookController.accountList.isEmpty()){
                update MapInvoiceToQuickBookController.accountList.values();
            }
            if(!MapInvoiceToQuickBookController.OpportunityList.isEmpty()){
                update MapInvoiceToQuickBookController.OpportunityList.values();
            }
            if(!MapInvoiceToQuickBookController.SalesTermsmap.isEmpty()){
                update MapInvoiceToQuickBookController.SalesTermsmap.values();
            }
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    //Invoice Sync
    public static  RemoteSaveResult syncInvoice(string invId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isInvoiceManualSync=true;
            String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c','Balance__c','Invoice_Number__c'};
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
            if(!QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',FieldsToQuery,false) 
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
            {       
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            
            Invoice__c invObj=MapCustomInvoiceToQuickBookController.createInvoiceQB(invId);
            if(invObj!=Null && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update invObj;
                
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
           
            if(!MapCustomInvoiceToQuickBookController.prodList.isEmpty()){
                update MapCustomInvoiceToQuickBookController.prodList.values();
            }  
            if(serviceObject!=Null){
                if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount))
                    serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount))
                    serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                
                update serviceObject;
            }
            if(!MapCustomInvoiceToQuickBookController.accountList.isEmpty()){
                update MapCustomInvoiceToQuickBookController.accountList.values();
            }
            if(!MapCustomInvoiceToQuickBookController.OpportunityList.isEmpty()){
                update MapCustomInvoiceToQuickBookController.OpportunityList.values();
            }
            if(!MapCustomInvoiceToQuickBookController.SalesTermsmap.isEmpty()){
                update MapCustomInvoiceToQuickBookController.SalesTermsmap.values();
            }
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    //sync Product
    public static  RemoteSaveResult  syncProduct(string prodId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isProductManualSync=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) 
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false))
            {
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            Product2 prod=MapItemToQuickBookController.createItem(prodId);
            if(prod!=Null  && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update prod;
                
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
            
            if(serviceObject!=Null){
                if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount))
                    serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount))
                    serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                
                update serviceObject;
            }
            
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    //sync Sales Term
    public static  RemoteSaveResult  syncTerm(string TermId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            isTermManualSync=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','QB_Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
            {       
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            
            Terms__c SalesTerm=MapSalesTermsToQuickBookController.createterm(TermId);
            if(SalesTerm!=Null && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                update SalesTerm;
                
                wrap.success=true;
                wrap.errorMessage='Insert/update to QuickBooks synced successfully.';
            }else{
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    //Fetch Payments
    public static RemoteSaveResult readAllPayments(string oppId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        opportunity oppObj=null;
        try {
            string [] FieldsToQuery = new String [] {'QB_Id__c','Id'};
            if(QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery,False))
                oppObj=[SELECT QB_Id__c,Id FROM opportunity where id =:oppId limit 1];
            else{     
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            
            String [] FieldsToQuery3 = new String [] {'QB_Id__c','Total_Amount__c','Transaction_Date__c','QB_Job_Id__c','PaymentRefNum__c','Last_Sync_Date__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',Null,True)  
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',FieldsToQuery3,false)  
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',FieldsToQuery3,false)){
                    
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            List<Payment__c> ListToUpsert=MapPaymentToQuickBookController.readAllPaymentsQB(oppObj,Null);
            if(ListToUpsert!=Null && !ListToUpsert.isEmpty() && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                
                upsert ListToUpsert QB_Id__c;
                
                wrap.success=true;
                wrap.errorMessage='Record fetched successfully.';
            }else if(ListToUpsert!=Null && ListToUpsert.isEmpty() && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                wrap.success=true;
                wrap.errorMessage='No records found.';
            }else if(string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
            
        }catch (System.XMLException e) {  // invalid XML
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
       return wrap;
    }
    //Fetch invoices
    public static RemoteSaveResult readAllInvoices(string oppId){
        QuickbooksUtility.IsCalledFromLightning=true;
        RemoteSaveResult wrap=new RemoteSaveResult();
        opportunity oppObj=null;
        try {
            string [] FieldsToQuery1 = new String [] {'QB_Id__c','Id'};
            if(QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery1,False))
                oppObj=[SELECT QB_Id__c,Id FROM opportunity where id =:oppId limit 1];
            else{     
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap; 
            }
            
            String [] FieldsToQuery = new String [] {'QB_Id__c','Invoice_Date__c','Invoice_Number__c','BillEmail__c','DueDate__c','Balance__c','Last_Sync_Date__c','QB_Error__c','Shipment_Tracking_Number__c','Ship_Date__c','Private_Note__c','Copy_Address_from__c','CustomerMemo__c','BillingName__c','BillingStreet__c','BillingState__c','BillingCity__c','BillingCountry__c','BillingPostalCode__c','ShippingName__c','ShippingStreet__c','ShippingState__c','ShippingCity__c','ShippingCountry__c','ShippingPostalCode__c','Shipping_Method__c'};
            if(!QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True)  
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',FieldsToQuery,False)
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',FieldsToQuery,False))
            {
                wrap.success=false;
                wrap.errorMessage='Insufficient access.';
                return wrap;
            }
            
            List<Invoice__c> ListToUpsert=GetinvoicesFromQuickbooksController.readAllInvoicesQB(oppObj,Null);
            
            if(ListToUpsert!=Null && !ListToUpsert.isEmpty() && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                
                upsert ListToUpsert QB_Id__c;
                
                wrap.success=true;
                wrap.errorMessage='Record fetched successfully.';
            }else if(ListToUpsert!=Null && ListToUpsert.isEmpty() && string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                wrap.success=true;
                wrap.errorMessage='No records found.';
            }else if(string.isBlank(QuickbooksUtility.ErrorPageMessage)){
                wrap.success=false;
                wrap.errorMessage=QuickbooksUtility.ErrorPageMessage;
            }
          
        }catch (System.XMLException e) { 
            QB_Logger.GetLogger('QBConnectSyncUtility').LogError(e.getMessage(), e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    
    //Wrapper clases 
    global class RemoteSaveResult{
     
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public String errorMessage{get;set;}
    }
 }
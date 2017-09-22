/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
global with sharing class MapAccountToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private final Id AccId;
    private ApexPages.StandardController stdController;
    public static  QuickBookAuthDetails1__c serviceObject; 
    public static  Boolean isAccountManualSync=False;
    public static string QB_ID='';
    public MapAccountToQuickBookController(ApexPages.StandardController stdController) {
         AccId= (ID)stdController.getRecord().Id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    
    public PageReference createAccount(){
        try{
            isDisplayed=true;
            isAccountManualSync=true;
            String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery,False)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True))
            {
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            Account acc=createAccountQB(AccId);
            if(acc!=Null){
                update acc;
            }
        }catch(Exception e){
            QuickbooksUtility.AddPageMessages(e.getMessage());
            
            QB_Logger.GetLogger('MapAccountToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    public static Account createAccountQB(Id AccId){
        string SynchToken;
        serviceObject = QuickbooksUtility.getServiceSettings();
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
            QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
            return null;
         }
         
        String [] FieldsToQuery = new String [] {'name','Fax','Website,phone','billingStreet','BillingCity','billingState','BillingCountry','BillingPostalCode','ShippingStreet','ShippingState','ShippingCity','ShippingCountry','ShippingPostalCode','QB_Id__c','Description','Email_Address__c','Last_Sync_Date__c','QB_Error__c'};
        if(!QuickbooksUtility.CheckFieldPermission('account','isAccessible',FieldsToQuery,False)){
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
        Account acc=[select id,QB_Id__c,Last_Sync_Date__c,QB_Error__c from Account where id =:AccId limit 1];
        
        if(acc.QB_Id__c!=Null && acc.QB_Id__c!='' && (acc.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
            SynchToken=QuickbooksUtility.readAccount(serviceObject.Company_Id__c,acc.QB_Id__c.split('-')[1]);
        }
        
        string reqBody=createAccountDataJson(SynchToken,AccId,serviceObject.Company_Id__c);
        
        string updateOpp=((acc.QB_Id__c!=Null && acc.QB_Id__c!='' && (acc.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/customer'+updateOpp;
        
        HttpResponse res = QuickbooksUtility.makeCalloutToQuickBooks(endpoint,reqBody);
        
        if(res.getStatusCode()==200){
            
            MapOpportunityToQuickBookController.CustomerJsonParserResponse objToSave=(MapOpportunityToQuickBookController.CustomerJsonParserResponse)System.JSON.deserialize(res.getBody(), MapOpportunityToQuickBookController.CustomerJsonParserResponse.class);
            
            acc.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Customer.Id;
            acc.Last_Sync_Date__c=System.now();
            acc.QB_Error__c='';
            QB_ID='';
               
            return acc;
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            acc.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
            return acc;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            
            if(errorObj.Fault.Error[0].Message=='Duplicate Name Exists Error'){
                String AccountName=[select Name from Account where Id=:AccId limit 1].Name;
                QB_ID=QuickbooksUtility.QueryFromQB(serviceObject.Company_Id__c,AccountName,'Account');
                if(string.isNotBlank(QB_ID)){
                    SynchToken=QuickbooksUtility.readAccount(serviceObject.Company_Id__c,QB_ID);
        
                    string reqBody1=createAccountDataJson(SynchToken,AccId,serviceObject.Company_Id__c);
                    String endpoint1 = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/customer?operation=update';
                    
                    HttpResponse res1 = QuickbooksUtility.makeCalloutToQuickBooks(endpoint1,reqBody1);
                    
                    if(res1.getStatusCode()==200){
                        
                        MapOpportunityToQuickBookController.CustomerJsonParserResponse objToSave1=(MapOpportunityToQuickBookController.CustomerJsonParserResponse)System.JSON.deserialize(res1.getBody(), MapOpportunityToQuickBookController.CustomerJsonParserResponse.class);
                        acc.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave1.Customer.Id;
                        acc.Last_Sync_Date__c=System.now();
                        acc.QB_Error__c='';
                        QB_ID='';
                        
                        return acc;
                    }
                }
            }
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            acc.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Account Error : '+ErrorToShow);
            QB_Logger.GetLogger('MapAccountToQuickBookController').LogError('Account Sync callout to QB Error(Record - '+acc.id+') : '+ErrorToShow);
        }
        return acc;
          
    }
    public static string createAccountDataJson(String SynchToken,Id AccId,String CompanyId){
        Account acc=new Account();
        
        acc=[select id,name,Fax,Website,phone,billingStreet,BillingCity,billingState,BillingCountry,BillingPostalCode,ShippingStreet,ShippingState,ShippingCity,ShippingCountry,ShippingPostalCode,QB_Id__c,Description,Email_Address__c,Last_Sync_Date__c,QB_Error__c from Account where id =:AccId limit 1];
        //Main Wrapper
        MapOpportunityToQuickBookController.CustomerJsonParser wrap= new MapOpportunityToQuickBookController.CustomerJsonParser();
        
        MapOpportunityToQuickBookController.cls_BillAddr billAdd= new MapOpportunityToQuickBookController.cls_BillAddr();
            if(acc.billingStreet!=Null)
                billAdd.Line1=acc.billingStreet.substring(0, Math.min(acc.billingStreet.length(), 500));
            if(acc.billingState!=Null)
                billAdd.CountrySubDivisionCode=acc.billingState.substring(0, Math.min(acc.billingState.length(), 255));
            if(acc.BillingCity!=Null)
                billAdd.City=acc.BillingCity.substring(0, Math.min(acc.BillingCity.length(), 255));
            if(acc.BillingCountry!=Null)
                billAdd.Country=acc.BillingCountry.substring(0, Math.min(acc.BillingCountry.length(), 255));
            if(acc.BillingPostalCode!=Null)
                billAdd.PostalCode=acc.BillingPostalCode.substring(0, Math.min(acc.BillingPostalCode.length(), 31));
            
            wrap.BillAddr=billAdd;
        
        MapOpportunityToQuickBookController.cls_ShipAddr shipAdd= new MapOpportunityToQuickBookController.cls_ShipAddr();
            if(acc.ShippingStreet!=Null)
                shipAdd.Line1=acc.ShippingStreet.substring(0, Math.min(acc.ShippingStreet.length(), 500));
            if(acc.ShippingState!=Null)
                shipAdd.CountrySubDivisionCode=acc.ShippingState.substring(0, Math.min(acc.ShippingState.length(), 255));
            if(acc.ShippingCity!=Null)
                shipAdd.City=acc.ShippingCity.substring(0, Math.min(acc.ShippingCity.length(), 255));
            if(acc.ShippingCountry!=Null)
                shipAdd.Country=acc.ShippingCountry.substring(0, Math.min(acc.ShippingCountry.length(), 255));
            if(acc.ShippingPostalCode!=Null)
                shipAdd.PostalCode=acc.ShippingPostalCode.substring(0, Math.min(acc.ShippingPostalCode.length(), 31));
            
            wrap.ShipAddr=shipAdd;
            
        if(acc.phone!=Null){
            MapOpportunityToQuickBookController.cls_PrimaryPhone ph=new MapOpportunityToQuickBookController.cls_PrimaryPhone();
                ph.FreeFormNumber=acc.phone.substring(0, Math.min(acc.phone.length(), 21));
                wrap.PrimaryPhone=ph;
        }
        if(acc.Fax!=Null){    
            MapOpportunityToQuickBookController.cls_FAX faxObj=new MapOpportunityToQuickBookController.cls_FAX();
                faxObj.FreeFormNumber=acc.Fax.substring(0, Math.min(acc.Fax.length(), 21));
                wrap.Fax=faxObj;
        }    
        MapOpportunityToQuickBookController.cls_PrimaryEmailAddr email= new MapOpportunityToQuickBookController.cls_PrimaryEmailAddr();
            email.Address= acc.Email_Address__c; 
            wrap.PrimaryEmailAddr=email;
        
        if(String.isNotBlank(SynchToken)){
            wrap.Id=(string.isNotBlank(QB_Id) ? QB_Id : acc.QB_Id__c.split('-')[1]);
            wrap.sparse=true;
            wrap.SyncToken=SynchToken;
        }
        
        if(acc.Description!=NULL)
            wrap.Notes=acc.Description.substring(0, Math.min(acc.Description.length(), 2000));
        wrap.GivenName=acc.Name.substring(0, Math.min(acc.Name.length(), 25));
        wrap.CompanyName=acc.Name.substring(0, Math.min(acc.Name.length(), 50));
        wrap.DisplayName=acc.Name;/*.substring(0, Math.min(acc.Name.length(), 100));*/
        wrap.FullyQualifiedName=acc.Name;
        
        if(String.isNotBlank(acc.Website)){    
            MapOpportunityToQuickBookController.cls_WebAddr web= new MapOpportunityToQuickBookController.cls_WebAddr();
            string Website=acc.Website.toLowerCase().replaceAll('http://','').replaceAll('www.','').replaceAll('https://','').trim();
            if(Website.endsWith('.')){
                Website=Website.substring(0, (Website.length()-1));
            }
            web.URI='http://www.'+Website;
            
            wrap.WebAddr=web;
        }
        
        wrap.Taxable=true;
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    public PageReference redirectToAccount(){
        PageReference reference=new PageReference('/'+AccId);
        reference.setRedirect(true);
        return reference;
    }
    
}
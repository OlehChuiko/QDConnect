/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapOpportunityToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private final Id oppId;
    private ApexPages.StandardController stdController;
    public static Boolean isAccountUpdated=false;
    public static  Boolean isOppManualSync=False;
    public static Map<Id,Account> isAccountUpdatedMap=new  Map<Id,Account>();
    public static QuickBookAuthDetails1__c serviceObject; 
    public static string QB_ID='';
    public MapOpportunityToQuickBookController (ApexPages.StandardController stdController) {
         oppId= (ID)stdController.getRecord().Id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    public PageReference createOpp(){
        try{
            isOppManualSync=true;
            isDisplayed=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
            {       
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            Opportunity opp=createOppQB(oppId);
            if(opp!=Null){
                update opp;
                if(!isAccountUpdatedMap.isEmpty()){
                    update isAccountUpdatedMap.values();
                }
            }
        }catch(Exception e){
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('MapOpportunityToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    public static Opportunity createOppQB(Id oppId){
        
        string SynchToken;
        serviceObject = QuickbooksUtility.getServiceSettings();
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
        
        String [] FieldsToQuery = new String [] {'AccountId','QB_Id__c','Description','Id','Name','Last_Sync_Date__c','QB_Error__c'};
        String [] FieldsToQuery2 = new String [] {'QB_Id__c','Name','Fax','Website','phone','billingStreet','billingState','BillingCity','BillingCountry','BillingPostalCode','ShippingStreet','ShippingState','ShippingCity','ShippingCountry','ShippingPostalCode'};
        if(!QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery,False) || !QuickbooksUtility.CheckFieldPermission('account','isAccessible',FieldsToQuery2,False))
        {
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
        Opportunity opp=[SELECT AccountId,QB_Id__c,Last_Sync_Date__c,QB_Error__c FROM Opportunity where id =:oppId limit 1];
         
        if(string.isBlank(opp.AccountId)){
             QuickbooksUtility.AddPageMessages('Opportunity Error : Account field is always required to create a Job in QuickBooks.');
             return null;
        }
    
        if(opp.QB_Id__c!=Null && opp.QB_Id__c!='' && (opp.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
            SynchToken=QuickbooksUtility.readAccount(serviceObject.Company_Id__c,opp.QB_Id__c.split('-')[1]);
        }
        string reqBody=createOpptyDataJson(SynchToken,oppId,serviceObject.Company_Id__c);
        
        string updateOpp=((opp.QB_Id__c!=Null && opp.QB_Id__c!='' && (opp.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/customer'+updateOpp;

        HttpResponse res = QuickbooksUtility.makeCalloutToQuickBooks(endpoint,reqBody);
        
        if(res.getStatusCode()==200){
            CustomerJsonParserResponse objToSave=(CustomerJsonParserResponse)System.JSON.deserialize(res.getBody(), CustomerJsonParserResponse.class);
            opp.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Customer.Id;
            opp.Last_Sync_Date__c=System.now();
            opp.QB_Error__c='';
            QB_ID='';
            
            
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            opp.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
            return opp;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            
            if(errorObj.Fault.Error[0].Message=='Duplicate Name Exists Error'){
                List<Opportunity> oppToQuery=[select Name,Account.name from Opportunity where Id=:oppId limit 1];
                QB_ID=QuickbooksUtility.QueryFromQB(serviceObject.Company_Id__c,oppToQuery[0].Account.Name+':'+oppToQuery[0].Name,'Opportunity');
                if(string.isNotBlank(QB_ID)){
                    SynchToken=QuickbooksUtility.readAccount(serviceObject.Company_Id__c,QB_ID);
        
                    string reqBody1=createOpptyDataJson(SynchToken,oppId,serviceObject.Company_Id__c);
                    String endpoint1 = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/customer?operation=update';
                    
                    HttpResponse res1 = QuickbooksUtility.makeCalloutToQuickBooks(endpoint1,reqBody1);
                    
                    if(res1.getStatusCode()==200){
                        
                        CustomerJsonParserResponse objToSave=(CustomerJsonParserResponse)System.JSON.deserialize(res1.getBody(), CustomerJsonParserResponse.class);
                        opp.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Customer.Id;
                        opp.Last_Sync_Date__c=System.now();
                        opp.QB_Error__c='';
                        QB_ID='';
                        
                        
                        return opp;
                    }
                }
            }
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            opp.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Opportunity Error : '+ErrorToShow);
            QB_Logger.GetLogger('MapOpportunityToQuickBookController').LogError('Opportunity Sync callout to QB Error(Record - '+opp.id+') : '+ErrorToShow);
        }
        return opp;
    }
    public static string createOpptyDataJson(String SynchToken,String oppId,String CompanyId){
        Opportunity opp=[SELECT AccountId,QB_Id__c,Account.QB_Id__c,Account.Name,Description,Id,Name,Last_Sync_Date__c,QB_Error__c,Account.Fax,Account.Website,Account.phone,Account.billingStreet,Account.billingState,Account.BillingCity,Account.BillingCountry,Account.BillingPostalCode,Account.ShippingStreet,Account.ShippingState,Account.ShippingCity,Account.ShippingCountry,Account.ShippingPostalCode FROM Opportunity where id =:oppId limit 1];
        //Main Wrapper
        CustomerJsonParser wrap= new CustomerJsonParser();
        
        ParentRef_cls parent= new ParentRef_cls();
            if(opp.Account.QB_Id__c!=Null && opp.Account.QB_Id__c!='' && (opp.Account.QB_Id__c.split('-')[0]==CompanyId)){
                parent.value=opp.Account.QB_Id__c.split('-')[1];
            }else if(isAccountUpdatedMap.containsKey(opp.AccountId) && String.isNotBlank(isAccountUpdatedMap.get(opp.AccountId).QB_Id__c)){
                parent.value=isAccountUpdatedMap.get(opp.AccountId).QB_Id__c.split('-')[1];
            }else{
                Account acc=MapAccountToQuickBookController.createAccountQB(opp.AccountId);
                if(acc!=Null){
                    isAccountUpdatedMap.put(opp.AccountId,acc);
                    parent.value=acc.QB_Id__c.split('-')[1];
                }
            }
            wrap.ParentRef=parent;
        
        cls_BillAddr billAdd= new cls_BillAddr();
            if(opp.Account.billingStreet!=Null)
                billAdd.Line1=opp.Account.billingStreet.substring(0, Math.min(opp.Account.billingStreet.length(), 500));
            if(opp.Account.billingState!=Null)
                billAdd.CountrySubDivisionCode=opp.Account.billingState.substring(0, Math.min(opp.Account.billingState.length(), 255));
            if(opp.Account.BillingCity!=Null)
                billAdd.City=opp.Account.BillingCity.substring(0, Math.min(opp.Account.BillingCity.length(), 255));
            if(opp.Account.BillingCountry!=Null)
                billAdd.Country=opp.Account.BillingCountry.substring(0, Math.min(opp.Account.BillingCountry.length(), 255));
            if(opp.Account.BillingPostalCode!=Null)
                billAdd.PostalCode=opp.Account.BillingPostalCode.substring(0, Math.min(opp.Account.BillingPostalCode.length(), 31));
            
            wrap.BillAddr=billAdd;
        
        cls_ShipAddr shipAdd= new cls_ShipAddr();
            if(opp.Account.ShippingStreet!=Null)
                shipAdd.Line1=opp.Account.ShippingStreet.substring(0, Math.min(opp.Account.ShippingStreet.length(), 500));
            if(opp.Account.ShippingState!=Null)
                shipAdd.CountrySubDivisionCode=opp.Account.ShippingState.substring(0, Math.min(opp.Account.ShippingState.length(), 255));
            if(opp.Account.ShippingCity!=Null)
                shipAdd.City=opp.Account.ShippingCity.substring(0, Math.min(opp.Account.ShippingCity.length(), 255));
            if(opp.Account.ShippingCountry!=Null)
                shipAdd.Country=opp.Account.ShippingCountry.substring(0, Math.min(opp.Account.ShippingCountry.length(), 255));
            if(opp.Account.ShippingPostalCode!=Null)
                shipAdd.PostalCode=opp.Account.ShippingPostalCode.substring(0, Math.min(opp.Account.ShippingPostalCode.length(), 31));
            
            wrap.ShipAddr=shipAdd;
            
        if(opp.Account.phone!=Null){    
            cls_PrimaryPhone ph=new cls_PrimaryPhone();
                ph.FreeFormNumber=opp.Account.phone.substring(0, Math.min(opp.Account.phone.length(), 21));
                wrap.PrimaryPhone=ph;
        }
        if(opp.Account.Fax!=Null){      
            cls_FAX faxObj=new cls_FAX();
                faxObj.FreeFormNumber=opp.Account.Fax.substring(0, Math.min(opp.Account.Fax.length(), 21));
                wrap.Fax=faxObj;
        }    
        
        if(String.isNotBlank(SynchToken)){
            wrap.Id=(string.isNotBlank(QB_Id) ? QB_Id : opp.QB_Id__c.split('-')[1]);
            wrap.sparse=true;
            wrap.SyncToken=SynchToken;
        }
        
        if(opp.Description!=NULL)
            wrap.Notes=opp.Description.substring(0, Math.min(opp.Description.length(), 2000));
        
        wrap.GivenName=opp.Name.substring(0, Math.min(opp.Name.length(), 25));
        wrap.CompanyName=opp.Account.Name.substring(0, Math.min(opp.Account.Name.length(), 50));
        wrap.DisplayName=opp.Name;/*.substring(0, Math.min(opp.Name.length(), 100));*/
        wrap.Job=true;
        wrap.Taxable=true;
        
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    
    public PageReference redirectToOpp(){
        PageReference reference=new PageReference('/'+oppId);
        reference.setRedirect(true);
        return reference;
    }
    
    //Wrappers for Customer Parsing
    public class CustomerJsonParserResponse{
        public CustomerJsonParser Customer;
    }
    public class CustomerJsonParser{
        public MetaData_cls MetaData;
        public Boolean Job;
        public Boolean Taxable;
        public Boolean sparse;
        public String SyncToken;
        public ParentRef_cls ParentRef;
        public cls_BillAddr BillAddr;
        public cls_ShipAddr ShipAddr;
        public String Notes;    //Here are other details.
        public String Id;
        public String Title;    //Mr
        public String GivenName;    //James
        public String MiddleName;   //B
        public String FamilyName;   //King
        public String Suffix;   //Jr
        public String FullyQualifiedName;   //King Groceries
        public String CompanyName;  //King Groceries
        public String DisplayName;  //King's Groceries
        public cls_PrimaryPhone PrimaryPhone;
        public cls_PrimaryEmailAddr PrimaryEmailAddr;
        public cls_WebAddr WebAddr;
        public cls_FAX Fax;
    }
    public class MetaData_cls {
        public DateTime CreateTime;
        public DateTime LastUpdatedTime;
    }
    public class ParentRef_cls {
        public String name;    
        public String type; 
        public String value;
    }
    public class cls_BillAddr {
        public String Line1;    //123 Main Street
        public String Line2;    
        public String City; //Mountain View
        public String Country;  //USA
        public String CountrySubDivisionCode;   //CA
        public String PostalCode;   //94042
    }
    public class cls_ShipAddr {
        public String Line1;    //123 Main Street
        public String Line2;
        public String City; //Mountain View
        public String Country;  //USA
        public String CountrySubDivisionCode;   //CA
        public String PostalCode;   //94042
    }
    public class cls_PrimaryPhone {
        public String FreeFormNumber;   //(555) 555-5555
    }
    public class cls_FAX {
        public String FreeFormNumber;   //(555) 555-5555
    }
    public class cls_PrimaryEmailAddr {
        public String Address;  //jdrew@myemail.com
    }
    public class cls_WebAddr {
        public String URI;
    }
    
}
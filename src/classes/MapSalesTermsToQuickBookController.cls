/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapSalesTermsToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private Id TermId;
    private ApexPages.StandardController stdController;
    public static QuickBookAuthDetails1__c serviceObject; 
    public static  Boolean isTermManualSync=False;
    public MapSalesTermsToQuickBookController (ApexPages.StandardController stdController) {
         TermId= (Id)stdController.getRecord().id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    
    public PageReference createTerm(){
        try{
            isDisplayed=true;
            isTermManualSync=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','QB_Last_Sync_Date__c','QB_Error__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
            {       
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            
            Terms__c prod=createterm(TermId);
            if(prod!=Null){
                update prod;
            }
            
        }catch(Exception e){
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('MapSalesTermsToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    
    public static  Terms__c createterm(Id TermId){
        string SynchToken;
        serviceObject = QuickbooksUtility.getServiceSettings();
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
        
        String [] FieldsToQuery = new String [] {'id','Name','Is_Active__c','QB_Id__c','Type__c','QB_Last_Sync_Date__c','QB_Error__c','Discount_Day_Of_Month__c','Due_Next_Month_Days__c','Due_Days__c','Discount_Percent__c','Discount_Days__c','Day_Of_Month_Due__c'};
        if(!QuickbooksUtility.CheckFieldPermission('Terms__c','isAccessible',FieldsToQuery,False))
        {
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
        Terms__c prod=[SELECT id,Name,Is_Active__c,QB_Id__c,Type__c,QB_Last_Sync_Date__c,QB_Error__c,Discount_Day_Of_Month__c,Due_Next_Month_Days__c,Due_Days__c,Discount_Percent__c,Discount_Days__c,Day_Of_Month_Due__c FROM Terms__c where Id =:TermId limit 1];
        
        if(prod.QB_Id__c!=Null && prod.QB_Id__c!='' && (prod.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
            SynchToken=readTerm(prod.QB_Id__c.split('-')[1],serviceObject.Company_Id__c);
        }else{
            //Query Term if already created on QB.code starts
            String QB_ID='';
            QB_ID=QuickbooksUtility.QueryFromQB(serviceObject.Company_Id__c,prod.Name,'term');
            if(string.isNotBlank(QB_ID)){
                prod.QB_Id__c=serviceObject.Company_Id__c+'-'+QB_ID;
                prod.QB_Error__c='';
                
                
                return prod;
            //Query Term if already created on QB.code ends
            }
        }
        string str=createtermDataJson(SynchToken,prod,serviceObject.Company_Id__c);
        
        string updateOpp=((prod.QB_Id__c!=Null && prod.QB_Id__c!='' && (prod.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/term'+updateOpp;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');   
        req.setBody(str);
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('Accept' , 'application/json');
        req.setHeader('content-type', 'application/json');
            
        HttpResponse res;
        res = http.send(req); 
        if(res.getStatusCode()==200){
                TermJSON objToSave=(TermJSON)System.JSON.deserialize(res.getBody(), TermJSON.class);
                prod.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.term.Id;
                prod.QB_Last_Sync_Date__c=System.now();
                prod.QB_Error__c='';
                
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            prod.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            prod.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Term Error : '+ErrorToShow);
            QB_Logger.GetLogger('MapSalesTermsToQuickBookController').LogError('Term Sync callout to QB Error(Record - '+prod.id+') : '+ErrorToShow);
        }
        return prod;
    }
    public static String readterm(String termId,String CompanyId){
            String SynchToken;
            String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/term/'+termId;

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint(endpoint);
            req.setMethod('GET');   
            req = QuickbooksAPI.signRequest(req);
            req.setHeader('Accept' , 'application/json');
            req.setHeader('content-type', 'application/json');
                
            HttpResponse res;
            res = http.send(req); 
            
            if(res.getStatusCode()==200){
                TermJSON objToSave=(TermJSON)System.JSON.deserialize(res.getBody(), TermJSON.class);
                SynchToken=objToSave.term.SyncToken;
            }else if(res.getStatusCode()==401){
                QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
                
            }else{
                QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
                string ErrorToShow=errorObj.Fault.Error[0].Detail;
                QuickbooksUtility.AddPageMessages('Term Error : '+ErrorToShow);
            }
        return SynchToken;
          
    }
    public static string createtermDataJson(String SynchToken,Terms__c prod,String CompanyId){
        
        cls_term wrap= new cls_term();
        
            if(String.isNotBlank(SynchToken)){
                wrap.Id=prod.QB_Id__c.split('-')[1];
                wrap.SyncToken=SynchToken;
                wrap.sparse=true;
            }
            
            wrap.Name=prod.Name;
            wrap.Active=prod.Is_Active__c;
            wrap.Type=prod.Type__c;
            wrap.DiscountPercent=prod.Discount_Percent__c;
            wrap.DueNextMonthDays=prod.Due_Next_Month_Days__c;
            wrap.DueDays=prod.Due_Days__c;
            wrap.DiscountDays=prod.Discount_Days__c;
            wrap.DiscountDayOfMonth=prod.Discount_Day_Of_Month__c;
            wrap.DayOfMonthDue=prod.Day_Of_Month_Due__c;
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
   
    public PageReference redirectToterm(){
        PageReference reference=new PageReference('/'+TermId);
        reference.setRedirect(true);
        return reference;
    }
    
    //Wrapper for Response parsing
    public class TermJSON{
        public cls_Term Term;
    }
    public class cls_Term {
        public String Name; //Term120
        public boolean Active;
        public String Type; //STANDARD
        public Decimal DiscountPercent; //0
        public Decimal DueDays; //120
        public String domain;   //QBO
        public boolean sparse;
        public String Id;   //8
        public String SyncToken;    //0
        public cls_MetaData MetaData;
        public Decimal DayOfMonthDue;
        public Decimal DiscountDays;
        public Decimal DueNextMonthDays;
        public Decimal DiscountDayOfMonth;
    }
    public class cls_MetaData {
        public String CreateTime;   //2015-07-28T08:50:59-07:00
        public String LastUpdatedTime;  //2015-07-28T08:50:59-07:00
    }
    
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapPaymentToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private final opportunity oppObj;
    private ApexPages.StandardController stdController;
    public Static QuickBookAuthDetails1__c serviceObject; 
    public MapPaymentToQuickBookController(ApexPages.StandardController stdController) {
        id oppId= (ID)stdController.getRecord().Id;
        this.stdController = stdController;
        string [] FieldsToQuery = new String [] {'QB_Id__c','Id'};
        if(QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery,False))
            oppObj=[SELECT QB_Id__c,Id FROM opportunity where id =:oppId limit 1];
        else{     
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
        }
        isDisplayed=false;
   }      
    public PageReference readAllPayments(){
        try {
            isDisplayed=true;
            String [] FieldsToQuery3 = new String [] {'QB_Id__c','Total_Amount__c','Transaction_Date__c','QB_Job_Id__c','PaymentRefNum__c','Last_Sync_Date__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',Null,True)  
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',FieldsToQuery3,false)  
                || !QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',FieldsToQuery3,false)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
                return Null;
            }
            List<Payment__c> ListToUpsert=readAllPaymentsQB(oppObj,Null);
            if(ListToUpsert!=Null && !ListToUpsert.isEmpty()){
                upsert ListToUpsert QB_Id__c;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record fetched successfully.'));
            }else if(ListToUpsert!=Null && ListToUpsert.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No records found.'));
            }
            
        }catch (System.XMLException e) {  // invalid XML
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('MapPaymentToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
   
    public Static List<Payment__c> readAllPaymentsQB(opportunity oppObj,String SchTimer){
        serviceObject = QuickbooksUtility.getServiceSettings();
        List<Payment__c> ListToUpsert= new List<Payment__c>();
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
        
        if(String.isBlank(oppObj.QB_Id__c) || oppObj.QB_Id__c.split('-')[0]!=serviceObject.Company_Id__c){
            QuickbooksUtility.AddPageMessages('There is no matching Job [in QuickBooks] that related to this Opportunity. ');
            return Null;
        }
        String queryStr='';
        if(SchTimer!=Null && SchTimer!=''){
            queryStr='select%20%2A%20from%20payment%20where%20CustomerRef%20%3D%20%27'+oppObj.QB_Id__c.split('-')[1]+'%27%20and%20MetaData.LastUpdatedTime%20%3E%3D%20%27'+SchTimer+'%27';
        }else{
            queryStr='select%20%2A%20from%20Payment%20where%20CustomerRef%20%3D%27'+oppObj.QB_Id__c.split('-')[1]+'%27';
        }
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/query?query='+queryStr;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');   
        req = QuickbooksAPI.signRequest(req);
        //req.setHeader('content-type', 'application/json;charset=UTF-8');
        req.setHeader('Accept' , 'application/json');
            
        HttpResponse res;
        res = http.send(req); 
        
        if(res.getStatusCode()==200){
            
            PaymentJsonResponse jsonresponse=(PaymentJsonResponse)System.JSON.deserialize(res.getBody(), PaymentJsonResponse.class);
            if(jsonresponse.QueryResponse.Payment!=Null  && !jsonresponse.QueryResponse.Payment.isEmpty()){
                for(cls_Payment sr : jsonresponse.QueryResponse.Payment){
                    Payment__c SalesRecieptRecord = new Payment__c(Opportunity__c=oppObj.id);
                        
                    SalesRecieptRecord.QB_Id__c=serviceObject.Company_Id__c+'-'+sr.Id;
                    SalesRecieptRecord.Total_Amount__c =sr.TotalAmt;
                    SalesRecieptRecord.Transaction_Date__c =sr.TxnDate;
                    SalesRecieptRecord.QB_Job_Id__c =sr.CustomerRef.value;
                    SalesRecieptRecord.PaymentRefNum__c =sr.PaymentRefNum;
                    SalesRecieptRecord.Last_Sync_Date__c=Date.today();
                    ListToUpsert.add(SalesRecieptRecord);
                }
            }
        }
        return ListToUpsert;
    }
    Public PageReference Back(){
        PageReference reference=new PageReference('/'+oppObj.Id);
        reference.setRedirect(true);
        return reference;
    }
    ////Wrappers for Response Parsing 
    public class PaymentJsonResponse{
        public cls_QueryResponse QueryResponse;
    }
    Public class cls_QueryResponse {
        public cls_Payment[] Payment;
        public Integer startPosition;   //1
        public Integer maxResults;  //2
    }
    Public class cls_Payment {
        public String domain;   //QBO
        public boolean sparse;
        public String Id;   //13
        public String SyncToken;    //0
        public cls_MetaData MetaData;
        public Date TxnDate;    //2015-08-25
        public cls_CustomerRef CustomerRef;
        public Decimal TotalAmt;    //35
        public String PaymentRefNum;
    }
    Public class cls_MetaData {
        public String CreateTime;   //2015-08-25T23:00:49-07:00
        public String LastUpdatedTime;  //2015-08-25T23:00:49-07:00
    }
    
    Public class cls_CustomerRef {
        public String value;    //1
        public String name; //United Oil & Gas, UK
    }
    
}
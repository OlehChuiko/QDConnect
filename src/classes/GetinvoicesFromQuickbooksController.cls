/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class GetinvoicesFromQuickbooksController {
    public Boolean isDisplayed{get;set;}
   
    private final opportunity oppObj;
    private ApexPages.StandardController stdController;
    public Static QuickBookAuthDetails1__c serviceObject; 
    public GetinvoicesFromQuickbooksController(ApexPages.StandardController stdController) {
        id oppId= (ID)stdController.getRecord().Id;
        this.stdController = stdController;
        String [] FieldsToQuery = new String [] {'QB_Id__c','Id'};
        if(QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery,False))
            oppObj=[SELECT QB_Id__c,Id FROM opportunity where id =:oppId limit 1];
        else{     
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
        }
        isDisplayed=false;
   }      
    public PageReference readAllInvoices(){
        try {
            isDisplayed=true;
            List<Invoice__c> ListToUpsert=readAllInvoicesQB(oppObj,Null);
            String [] FieldsToQuery = new String [] {'QB_Id__c','Invoice_Date__c','Invoice_Number__c','BillEmail__c','DueDate__c','Balance__c','Last_Sync_Date__c','QB_Error__c','Shipment_Tracking_Number__c','Ship_Date__c','Private_Note__c','Copy_Address_from__c','CustomerMemo__c','BillingName__c','BillingStreet__c','BillingState__c','BillingCity__c','BillingCountry__c','BillingPostalCode__c','ShippingName__c','ShippingStreet__c','ShippingState__c','ShippingCity__c','ShippingCountry__c','ShippingPostalCode__c','Shipping_Method__c'};
            if(!QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True)  
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',FieldsToQuery,False)
                || !QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',FieldsToQuery,False))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
            }
            if(ListToUpsert!=Null && !ListToUpsert.isEmpty()){
                upsert ListToUpsert QB_Id__c;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Record fetched successfully.'));
            }else if(ListToUpsert!=Null && ListToUpsert.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No records found.'));
            }
          
        }catch (System.XMLException e) {  // invalid XML
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('GetinvoicesFromQuickbooksController').LogError(e.getMessage(), e);
        }
        return Null;
    }
   
    public Static List<Invoice__c> readAllInvoicesQB(opportunity oppObj,String SchTimer){
        serviceObject = QuickbooksUtility.getServiceSettings();
        List<Invoice__c> ListToUpsert= new List<Invoice__c>();
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
        
        if(String.isBlank(oppObj.QB_Id__c) || oppObj.QB_Id__c.split('-')[0]!=serviceObject.Company_Id__c){
            QuickbooksUtility.AddPageMessages('There is no matching Job [in QuickBooks] that related to this Opportunity.');
            return Null;
        }
        String queryStr='';
        if(SchTimer!=Null && SchTimer!=''){
            queryStr='select%20%2A%20from%20Invoice%20where%20CustomerRef%20%3D%20%27'+oppObj.QB_Id__c.split('-')[1]+'%27%20and%20MetaData.LastUpdatedTime%20%3E%3D%20%27'+SchTimer+'%27';
        }else{
            queryStr='select%20%2A%20from%20Invoice%20where%20CustomerRef%20%3D%27'+oppObj.QB_Id__c.split('-')[1]+'%27';
        }
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/query?query='+queryStr;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');   
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('Accept' , 'application/json');
            
        HttpResponse res;
        res = http.send(req); 
        
        if(res.getStatusCode()==200){
            
            InvoiceJsonResponse jsonresponse=(InvoiceJsonResponse)System.JSON.deserialize(res.getBody(), InvoiceJsonResponse.class);
            if(jsonresponse!= Null && jsonresponse.QueryResponse.Invoice!=Null  && !jsonresponse.QueryResponse.Invoice.isEmpty()){
                for(MapCustomInvoiceToQuickBookController.cls_Invoice sr : jsonresponse.QueryResponse.Invoice){
                        Invoice__c InvoicetRecord = new Invoice__c(Opportunity__c=oppObj.id);
                        InvoicetRecord.QB_Id__c=serviceObject.Company_Id__c+'-'+sr.Id;
                        InvoicetRecord.Invoice_Date__c=sr.TxnDate;
                        InvoicetRecord.Invoice_Number__c=sr.DocNumber;
                        
                        if(sr.BillEmail!=Null){
                          InvoicetRecord.BillEmail__c=sr.BillEmail.Address;
                        }
                        InvoicetRecord.DueDate__c=sr.DueDate;
                        InvoicetRecord.Balance__c =sr.Balance;
                        InvoicetRecord.Last_Sync_Date__c=System.now();
                        InvoicetRecord.QB_Error__c='';
                        InvoicetRecord.Shipment_Tracking_Number__c=sr.TrackingNum;
                        InvoicetRecord.Ship_Date__c=sr.ShipDate;
                        InvoicetRecord.Private_Note__c=sr.PrivateNote;
                        InvoicetRecord.Copy_Address_from__c='';
                        if(sr.CustomerMemo!=Null){
                            InvoicetRecord.CustomerMemo__c=sr.CustomerMemo.value;
                        }
                        if(sr.BillAddr!=Null){
                            InvoicetRecord.BillingName__c=sr.BillAddr.Line1;
                            InvoicetRecord.BillingStreet__c=sr.BillAddr.Line2;
                            InvoicetRecord.BillingState__c=sr.BillAddr.Line3;
                            InvoicetRecord.BillingCity__c=sr.BillAddr.City;
                            InvoicetRecord.BillingCountry__c=sr.BillAddr.Country;
                            InvoicetRecord.BillingPostalCode__c=sr.BillAddr.PostalCode;
                        }
                        if(sr.ShipAddr!=Null){
                            InvoicetRecord.ShippingName__c=sr.ShipAddr.Line1;
                            InvoicetRecord.ShippingStreet__c=sr.ShipAddr.Line2;
                            InvoicetRecord.ShippingState__c=sr.ShipAddr.Line3;
                            InvoicetRecord.ShippingCity__c=sr.ShipAddr.City;
                            InvoicetRecord.ShippingCountry__c=sr.ShipAddr.Country;
                            InvoicetRecord.ShippingPostalCode__c=sr.ShipAddr.PostalCode;
                        }
                        if(sr.ShipMethodRef!=Null){
                            InvoicetRecord.Shipping_Method__c=sr.ShipMethodRef.Value;
                        }
                        ListToUpsert.add(InvoicetRecord);
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
    //Invoice Wrappers
  public class InvoiceJsonResponse{
    public cls_QueryResponse QueryResponse;
  }
  
  public class cls_QueryResponse {
    public MapCustomInvoiceToQuickBookController.cls_Invoice[] Invoice;
    public Integer startPosition;  //1
    public Integer maxResults;  //3
    public Integer totalCount;  //3
  }
    
}
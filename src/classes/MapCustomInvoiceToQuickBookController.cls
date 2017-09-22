/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapCustomInvoiceToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private final id invId;
    private ApexPages.StandardController stdController;
    public static QuickBookAuthDetails1__c serviceObject; 
    public static QB_Fields_Mapping__c ObjectToMap;
    public static Map<Id,Product2> prodList= new Map<Id,Product2>();
    public static Map<Id,Account> accountList= new Map<Id,Account>();
    public static Map<Id,Opportunity> OpportunityList= new Map<Id,Opportunity>();
    public static Map<Id,Terms__c> SalesTermsmap= new Map<Id,Terms__c>();
    public static  Boolean isInvoiceManualSync=false;
    public MapCustomInvoiceToQuickBookController(ApexPages.StandardController stdController) {
         invId= (ID)stdController.getRecord().Id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    
    public PageReference createInvoice(){
        try{
            isDisplayed=true;
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
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            
            Invoice__c invObj=createInvoiceQB(invId);
            if(invObj!=Null){
                update invObj;
            }
           
            if(!prodList.isEmpty()){
                update prodList.values();
            }  
            if(serviceObject!=Null){
                if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount))
                    serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount))
                    serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                
                update serviceObject;
            }
            if(!accountList.isEmpty()){
                update accountList.values();
            }
            if(!OpportunityList.isEmpty()){
                update OpportunityList.values();
            }
            if(!SalesTermsmap.isEmpty()){
                update SalesTermsmap.values();
            }
            
        }catch(Exception e){
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('MapCustomInvoiceToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    
    public static Invoice__c createInvoiceQB(id invId){
        serviceObject = QuickbooksUtility.getServiceSettings();
        ObjectToMap=QuickbooksUtility.getMappingObject();
        string SynchToken;
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
                 
        String [] FieldsToQuery = new String [] {'name','Invoice_Number__c','Copy_Line_Item_Description_From__c','Invoice_Date__c','Balance__c','Total_Amount__c','Shipping_Method__c','Shipment_Tracking_Number__c','CustomerMemo__c','Private_Note__c','BillEmail__c','Ship_Date__c','DueDate__c','QB_Tax_Percent__c','Sales_Term__c','Id','QB_Id__c','BillingName__c','BillingStreet__c','BillingState__c','BillingCity__c','BillingCountry__c','BillingPostalCode__c','ShippingName__c','ShippingStreet__c','ShippingState__c','ShippingCity__c','ShippingCountry__c','ShippingPostalCode__c','Last_Sync_Date__c','QB_Error__c'};
        String [] FieldsToQuery2 = new String [] {'QB_Id__c'};
        String [] FieldsToQuery3 = new String [] {'Description','QB_Id__c'};
        String [] FieldsToQuery4 = new String [] {'Description','Id','ListPrice','Name','OpportunityId','Product2Id','ProductCode','Quantity','ServiceDate','TotalPrice','UnitPrice','Subtotal'};
        if(!QuickbooksUtility.CheckFieldPermission('Invoice__c','isAccessible',FieldsToQuery,False) 
              ||  !QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery2,False)
              ||  !QuickbooksUtility.CheckFieldPermission('Terms__c','isAccessible',FieldsToQuery2,False)
              ||  !QuickbooksUtility.CheckFieldPermission('Product2','isAccessible',FieldsToQuery3,False)
              ||  !QuickbooksUtility.CheckFieldPermission('opportunitylineitem','isAccessible',FieldsToQuery4,False))
        {
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
         Invoice__c invObj=[SELECT name,Invoice_Number__c,Copy_Line_Item_Description_From__c,Invoice_Date__c,Balance__c,Total_Amount__c,Shipping_Method__c,Shipment_Tracking_Number__c,CustomerMemo__c,Private_Note__c,BillEmail__c,Ship_Date__c,DueDate__c,QB_Tax_Percent__c,Sales_Term__c,Sales_Term__r.QB_Id__c,opportunity__r.QB_Id__c,Id,QB_Id__c,BillingName__c,BillingStreet__c,BillingState__c,BillingCity__c,BillingCountry__c,BillingPostalCode__c,ShippingName__c,ShippingStreet__c,ShippingState__c,ShippingCity__c,ShippingCountry__c,ShippingPostalCode__c,Last_Sync_Date__c,QB_Error__c FROM Invoice__c where id =:invId limit 1];
         List<OpportunityLineItem> oppLines=[SELECT Product2.Description,Product2.QB_Id__c,Description,Id,ListPrice,Name,OpportunityId,Product2Id,ProductCode,Quantity,ServiceDate,TotalPrice,UnitPrice,Subtotal FROM OpportunityLineItem where OpportunityId=:invObj.Opportunity__c];
         
         if(oppLines==Null || oppLines.IsEmpty()){
             QuickbooksUtility.AddPageMessages('There should be atleast one product line item added to an Opportunity in order to sync an invoice.');
             return null;
         }
        If(invObj.QB_Id__c!=Null && invObj.QB_Id__c!='' && (invObj.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
            SynchToken=QuickbooksUtility.readInvoice(serviceObject.Company_Id__c,invObj.QB_Id__c.split('-')[1],'invoice');
        }
        string str=createCustomInvoiceDataJson(SynchToken,invObj,oppLines,serviceObject.Company_Id__c,serviceObject.Tax_Agency__c);
        
        string updateOpp=((invObj.QB_Id__c!=Null && invObj.QB_Id__c!='' && (invObj.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/invoice'+updateOpp;

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
            InvoiceJsonParser objToSave=(InvoiceJsonParser)System.JSON.deserialize(res.getBody(), InvoiceJsonParser.class);
            invObj.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Invoice.Id;
            invObj.Last_Sync_Date__c=System.now();
            invObj.QB_Error__c='';
            invObj.Balance__c=objToSave.Invoice.Balance;
            invObj.Invoice_Number__c=objToSave.Invoice.DocNumber;
            
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            invObj.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            invObj.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Invoice Error : '+ErrorToShow);  
            QB_Logger.GetLogger('MapCustomInvoiceToQuickBookController').LogError('Invoice Sync callout to QB Error(Record - '+invObj.id+') : '+ErrorToShow);
        }
        return invObj;
    }
    public static string createCustomInvoiceDataJson(String SynchToken,Invoice__c invObj,List<OpportunityLineItem> oppLines,String CompanyId,String Tax_Agency){
        cls_Invoice wrap= new cls_Invoice();
        //Custom Fields
        List<cls_CustomField> fieldsWrapperList= new List<cls_CustomField>();
        if(string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingInvoice__c))
        {
            
            CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingInvoice__c, CustomFieldsListJson.class);
            if(!Obj.CustomField.isEmpty()){
                Set<String> CustomFieldSet= new Set<String>();
                For(cls_CustomField str : Obj.CustomField){
                    if(str.StringValue.trim()!=''){
                        CustomFieldSet.add(str.StringValue);
                    }
                }
                List<String> FieldsToQuery = new List<String>();
                FieldsToQuery.addAll(CustomFieldSet);
                if(!CustomFieldSet.isEmpty() && QuickbooksUtility.CheckFieldPermission('invoice__c','isAccessible',FieldsToQuery,False)){
                    //Map fields with actual fields
                    String string_query='select id';
                    For(String str1 : CustomFieldSet){
                        if(str1!='' && !str1.equalsignorecase('Id')){
                            string_query+=','+str1;
                        }
                    }
                    string_query+=' from Invoice__c where id=\''+String.escapeSingleQuotes(string.valueOf(invObj.Id))+'\'  limit 1';
                    sObject sObj = Database.query(string_query);
                    
                    if(sObj!=Null){
                        For(cls_CustomField str2 : Obj.CustomField){
                            if(String.isNotBlank(str2.StringValue)){
                                cls_CustomField wrapper= new cls_CustomField();
                                
                                wrapper.DefinitionId=str2.DefinitionId;
                                wrapper.Type=str2.Type;
                                wrapper.Name=str2.Name;
                                wrapper.StringValue=string.valueOf(sObj.get(str2.StringValue));
                                
                                fieldsWrapperList.add(wrapper);
                            }
                        }
                    }
                }
            }
        }
        //For Line Items
        List<cls_Line> wrapLine= new List<cls_Line>();
        for(OpportunityLineItem qli : oppLines)
        { 
            //For products
            cls_ItemRef ItemRef1 = new cls_ItemRef();
                if(qli.Product2.QB_Id__c!=Null && qli.Product2.QB_Id__c!='' && (qli.Product2.QB_Id__c.split('-')[0]==CompanyId)){
                    ItemRef1.value=qli.Product2.QB_Id__c.split('-')[1];
                }else{
                    if(prodList.containsKey(qli.Product2Id)){
                        ItemRef1.value=prodList.get(qli.Product2Id).QB_Id__c.split('-')[1];
                    }else{
                        Product2 prod=MapItemToQuickBookController.createItem(qli.Product2Id);
                        if(prod!=Null && prod.QB_Id__c!=Null){
                            ItemRef1.value=prod.QB_Id__c.split('-')[1];
                            prodList.put(prod.Id,prod);
                        }
                    }
                }
                
        
            //For TAX
            cls_TaxCodeRef taxobjRef=new cls_TaxCodeRef();
            taxobjRef.value='TAX';
            //For cls_SalesItemLineDetail
            cls_SalesItemLineDetail obj1= new cls_SalesItemLineDetail();
                obj1.ItemRef=ItemRef1;
                obj1.UnitPrice=qli.UnitPrice;
                obj1.Qty=qli.Quantity;
                obj1.ServiceDate=qli.ServiceDate;
                obj1.TaxCodeRef=taxobjRef;
                
            //For Line Object
            cls_Line clsObj= new cls_Line();
                //clsObj.LineNum=integer.valueOf(qli.LineNumber);
                clsObj.Amount=qli.Subtotal;
                if(invObj.Copy_Line_Item_Description_From__c=='Product')
                    clsObj.Description=qli.Product2.Description;
                else
                    clsObj.Description=qli.Description;
                
                
                clsObj.DetailType='SalesItemLineDetail';
                clsObj.SalesItemLineDetail=obj1;
            
            wrapLine.add(clsObj);
        }
        
        //For Opportunity Relation
        cls_CustomerRef cust= new cls_CustomerRef();
            if(invObj.opportunity__r.QB_Id__c!=Null && invObj.opportunity__r.QB_Id__c!='' && (invObj.opportunity__r.QB_Id__c.split('-')[0]==CompanyId)){
                cust.value=invObj.opportunity__r.QB_Id__c.split('-')[1];
            }else{
                if(OpportunityList.containsKey(invObj.opportunity__c)){
                    cust.value=OpportunityList.get(invObj.opportunity__c).QB_Id__c.split('-')[1];
                }else{
                    Opportunity opp=MapOpportunityToQuickBookController.createOppQB(invObj.opportunity__c);
                    if(opp!=Null && opp.QB_Id__c!=Null){
                        cust.value=opp.QB_Id__c.split('-')[1];
                        OpportunityList.put(opp.Id,opp);
                        if(!MapOpportunityToQuickBookController.isAccountUpdatedMap.isEmpty()){
                            accountList.putAll(MapOpportunityToQuickBookController.isAccountUpdatedMap);
                        }
                    }
                }
            }
        
        //For Billing Address fields
        cls_BillAddr billAd= new cls_BillAddr();
            billAd.Line1=invObj.BillingName__c;
            billAd.Line2=invObj.BillingStreet__c;
            billAd.CountrySubDivisionCode=invObj.BillingState__c;
            billAd.City=invObj.BillingCity__c;
            billAd.Country=invObj.BillingCountry__c;
            billAd.PostalCode=invObj.BillingPostalCode__c;
        
        cls_ShipAddr shipAd= new cls_ShipAddr();
            shipAd.Line1=invObj.ShippingName__c;
            shipAd.Line2=invObj.ShippingStreet__c;
            shipAd.CountrySubDivisionCode=invObj.ShippingState__c;
            shipAd.City=invObj.ShippingCity__c;
            shipAd.Country=invObj.ShippingCountry__c;
            shipAd.PostalCode=invObj.ShippingPostalCode__c;
        
        //Shipping info   
        if(String.isNotBlank(invObj.Shipping_Method__c)){
            cls_ShipMethodRef shipm=new cls_ShipMethodRef();
            shipm.Value=invObj.Shipping_Method__c;
            shipm.Name=invObj.Shipping_Method__c;
            wrap.ShipMethodRef=shipm;
        }
        //Sales Terms
        If(invObj.Sales_Term__c!=Null){
            cls_SalesTermRef salesTerm=new cls_SalesTermRef();
            if(invObj.Sales_Term__r.QB_Id__c!=Null && invObj.Sales_Term__r.QB_Id__c!='' && (invObj.Sales_Term__r.QB_Id__c.split('-')[0]==CompanyId)){
                    salesTerm.value=invObj.Sales_Term__r.QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
            }else{
                if(SalesTermsmap.containsKey(invObj.Sales_Term__c)){
                    salesTerm.value=SalesTermsmap.get(invObj.Sales_Term__c).QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
                }else{
                    Terms__c Term=MapSalesTermsToQuickBookController.createterm(invObj.Sales_Term__c);
                    if(Term!=Null && Term.QB_Id__c!=Null){
                        salesTerm.value=Term.QB_Id__c.split('-')[1];
                        SalesTermsmap.put(Term.Id,Term);
                        wrap.SalesTermRef=salesTerm;
                    }
                }
            }
        }
            
        wrap.ShipDate=invObj.Ship_Date__c;
        wrap.TrackingNum=invObj.Shipment_Tracking_Number__c;
        //Email 
        BillEmail_cls email= new BillEmail_cls();
        email.Address=invObj.BillEmail__c;
        
        
        if(String.isNotBlank(SynchToken)){
            wrap.Id=invObj.QB_Id__c.split('-')[1];
            wrap.SyncToken=SynchToken;
            wrap.sparse=true;
        }
        
        wrap.CustomField=fieldsWrapperList;
        wrap.Line=wrapLine;
        wrap.DueDate=invObj.DueDate__c;
        
        wrap.BillEmail=email;
        if(invObj.CustomerMemo__c!=NULL){
            cls_CustomerMemo custMemo= new cls_CustomerMemo();
            custMemo.value=invObj.CustomerMemo__c.substring(0, Math.min(invObj.CustomerMemo__c.length(), 1000));
            wrap.CustomerMemo=custMemo;
        }
        if(invObj.Private_Note__c!=NULL){
            wrap.PrivateNote=invObj.Private_Note__c.substring(0, Math.min(invObj.Private_Note__c.length(), 4000));
        }
        If(invObj.QB_Tax_Percent__c!=Null){
            //For TAX
            cls_TaxCodeRef taxobjRef1=new cls_TaxCodeRef();
            taxobjRef1.value=QuickbooksUtility.getTaxCode(invObj.QB_Tax_Percent__c,CompanyId,Tax_Agency);
            
            //For TAX field
            cls_TxnTaxDetail taxObj= new cls_TxnTaxDetail();
            //taxObj.TotalTax=invObj.QB_Tax_Percent__c;
            taxObj.TxnTaxCodeRef=taxobjRef1;
            //taxObj.TaxLine=cls_TaxLineList;
                
            
            wrap.TxnTaxDetail=taxObj;
        }
        //if(invObj.Name!=NULL)
        //    wrap.DocNumber=invObj.Name.substring(0, Math.min(invObj.Name.length(), 21));
        wrap.TxnDate=invObj.Invoice_Date__c;
        wrap.TotalAmt=invObj.Total_Amount__c;
        
        wrap.CustomerRef=cust;
        wrap.BillAddr=billAd;
        wrap.ShipAddr=shipAd;
            
            
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    
    public PageReference redirectToQuote(){
        PageReference reference=new PageReference('/'+invId);
        reference.setRedirect(true);
        return reference;
    }
    //Wrappers for JSON parsing for Invoice object
   
    public class InvoiceJsonParser{
        public cls_Invoice Invoice;
    }
    public class cls_Invoice {
        public Decimal Deposit; //0
        public boolean AllowIPNPayment;
        public boolean AllowOnlinePayment;
        public boolean AllowOnlineCreditCardPayment;
        public boolean AllowOnlineACHPayment;
        public String domain;   //QBO
        public boolean sparse;
        public String Id;   //238
        public String SyncToken;    //0
        public cls_MetaData MetaData;
        public cls_CustomField[] CustomField;
        public String DocNumber;    //1069
        public Date TxnDate;  //2015-07-24
        public cls_LinkedTxn[] LinkedTxn;
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public BillEmail_cls BillEmail;
        public String PrivateNote;
        public cls_CustomerRef CustomerRef;
        public cls_BillAddr BillAddr;
        public cls_ShipAddr ShipAddr;
        public Date DueDate;    //2015-08-23
        public Date ShipDate;
        public Decimal TotalAmt;    //100
        public boolean ApplyTaxAfterDiscount;
        public String PrintStatus;  //NeedToPrint
        public String EmailStatus;  //NotSet
        public Decimal Balance; //100
        public cls_CustomerMemo CustomerMemo;
        public String TrackingNum;
        public cls_ShipMethodRef ShipMethodRef;
        public cls_SalesTermRef SalesTermRef;
    }
    public class cls_SalesTermRef {
        public String value;  
        public String name; 
    }
    public class cls_ShipMethodRef {
        public String value;  
        public String name; 
    }
    public class cls_CustomerMemo {
        public String value;  
    }
    public class BillEmail_cls {
        public String Address;  
    }
    public class cls_MetaData {
        public DateTime CreateTime;   //2015-07-24T10:33:39-07:00
        public DateTime LastUpdatedTime;  //2015-07-24T10:33:39-07:00
    }
    public class cls_CustomField {
        public String DefinitionId; //1
        public String Name; //Crew #
        public String Type; //StringType
        public String StringValue;
    }
    public class cls_LinkedTxn {
    }
    public class cls_Line {
        public String Id;   //1
        public Integer LineNum; //1
        public String Description;
        public Decimal Amount;  //100
        public String DetailType;   //SalesItemLineDetail
        public cls_SalesItemLineDetail SalesItemLineDetail;
    }
    public class cls_SalesItemLineDetail {
        public cls_ItemRef ItemRef;
        public cls_TaxCodeRef TaxCodeRef;
        public Decimal UnitPrice;
        public Decimal Qty;
        public Date ServiceDate;
    }
    public class cls_ItemRef {
        public String value;    //1
        public String name; //Services
    }
   
    public class cls_TxnTaxDetail {
        public Decimal TotalTax;    
        public cls_TaxCodeRef TxnTaxCodeRef;
    }
    public class cls_TaxCodeRef {
        public String value;    //NON
    }
    public class cls_CustomerRef {
        public String value;    //1
        public String name; //Amy's Bird Sanctuary
    }
    public class cls_BillAddr {
        public String Line1;    
        public String Line2;  
        public String Line3; 
        public String CountrySubDivisionCode;    
        public String City; 
        public String PostalCode;   
        public String Country;  
    }
    public class cls_ShipAddr {
        public String Line1;    
        public String Line2;  
        public String Line3;
        public String CountrySubDivisionCode;    
        public String City; 
        public String PostalCode;   
        public String Country;  
    }
   
    //Wrapper for custom field JSON DeSerialisation
   public class CustomFieldsListJson{
        public cls_CustomField[] CustomField{get;set;}
   }
}
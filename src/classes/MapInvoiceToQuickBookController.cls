/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapInvoiceToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private final id quoteId;
    private ApexPages.StandardController stdController;
    public static QuickBookAuthDetails1__c serviceObject; 
    public static QB_Fields_Mapping__c ObjectToMap;
    public static Map<Id,Product2> prodList= new Map<Id,Product2>();
    public static Map<Id,Account> accountList= new Map<Id,Account>();
    public static Map<Id,Opportunity> OpportunityList= new Map<Id,Opportunity>();
    public static Map<Id,Terms__c> SalesTermsmap= new Map<Id,Terms__c>();
    public static  Boolean isQuoteManualSync=false;
    public MapInvoiceToQuickBookController (ApexPages.StandardController stdController) {
         quoteId= (ID)stdController.getRecord().Id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    public PageReference createInvoice(){
        try{
            isDisplayed=true;
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
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            quote quoteObj=createInvoiceQB(quoteId);
            if(quoteObj!=Null){
                update quoteObj;
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
            QB_Logger.GetLogger('MapInvoiceToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    public static Quote createInvoiceQB(Id quoteId){
        serviceObject = QuickbooksUtility.getServiceSettings();
        ObjectToMap=QuickbooksUtility.getMappingObject(); 
        string SynchToken;
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
         }
         
         
        String [] FieldsToQuery = new String [] {'Copy_Line_Item_Description_From__c','QB_Estimate_Status__c','status','QB_Object_Type__c','TotalPrice','QB_Shipping_Method__c','QB_Shipment_Tracking_Number__c','Sales_Term__c','QB_Ship_Date__c','QB_Private_Note__c','QB_Id__c','Tax','Txn_Date__c','EstimateNumber__c','Id','BillingName','BillingStreet','BillingState','BillingCity','BillingCountry','BillingPostalCode','ShippingName','ShippingStreet','ShippingState','ShippingCity','ShippingCountry','ShippingPostalCode','Email','ExpirationDate','Description','QB_Tax_Percent__c','Last_Sync_Date__c','QB_Error__c'};
        String [] FieldsToQuery2 = new String [] {'QB_Id__c'};
        String [] FieldsToQuery3 = new String [] {'Description','QB_Id__c'};
        String [] FieldsToQuery4 = new String [] {'Description','LineNumber','Product2Id','Quantity','QuoteId','ServiceDate','Subtotal','UnitPrice'};
        if(!QuickbooksUtility.CheckFieldPermission('Quote','isAccessible',FieldsToQuery,False) 
             || !QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery2,False)
             || !QuickbooksUtility.CheckFieldPermission('Terms__c','isAccessible',FieldsToQuery2,False)
             ||  !QuickbooksUtility.CheckFieldPermission('Product2','isAccessible',FieldsToQuery3,False)
             ||  !QuickbooksUtility.CheckFieldPermission('QuoteLineItem','isAccessible',FieldsToQuery4,False))
        {
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
        
        Quote quoteObj=[SELECT Copy_Line_Item_Description_From__c,QB_Estimate_Status__c,status,QB_Object_Type__c,TotalPrice,QB_Shipping_Method__c,QB_Shipment_Tracking_Number__c,Sales_Term__c,Sales_Term__r.QB_Id__c,QB_Ship_Date__c,QB_Private_Note__c,QB_Id__c,Tax,Txn_Date__c,EstimateNumber__c,opportunity.QB_Id__c,Id,BillingName,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode,ShippingName,ShippingStreet,ShippingState,ShippingCity,ShippingCountry,ShippingPostalCode,Email,ExpirationDate,Description,QB_Tax_Percent__c,Last_Sync_Date__c,QB_Error__c,(select Product2.Description,Product2.QB_Id__c,Description,LineNumber,Product2Id,Quantity,QuoteId,ServiceDate,Subtotal,UnitPrice FROM QuoteLineItems) FROM quote where id =:quoteId limit 1];
        
        if(quoteObj.QuoteLineItems.isEmpty()){
             QuickbooksUtility.AddPageMessages('There should be atleast one product line item added to a Quote in order to sync an invoice or estimate.');
             return null;
         }
        String QB_Object_Name;
        String str;
        if(quoteObj.QB_Object_Type__c=='Invoice'){
            QB_Object_Name='invoice';
            If(quoteObj.QB_Id__c!=Null && quoteObj.QB_Id__c!='' && (quoteObj.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
                SynchToken=QuickbooksUtility.readInvoice(serviceObject.Company_Id__c,quoteObj.QB_Id__c.split('-')[1],QB_Object_Name);
            }
            str=createInvoiceDataJson(SynchToken,quoteObj,serviceObject.Company_Id__c,serviceObject.Tax_Agency__c);
        }else{
            QB_Object_Name='estimate';
            If(quoteObj.QB_Id__c!=Null && quoteObj.QB_Id__c!='' && (quoteObj.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
                SynchToken=QuickbooksUtility.readInvoice(serviceObject.Company_Id__c,quoteObj.QB_Id__c.split('-')[1],QB_Object_Name);
            }
            str=createEstimateDataJson(SynchToken,quoteObj,serviceObject.Company_Id__c,serviceObject.Tax_Agency__c);
        }
        
        string updateOpp=((quoteObj.QB_Id__c!=Null && quoteObj.QB_Id__c!='' && (quoteObj.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/'+QB_Object_Name+updateOpp;

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
            if(QB_Object_Name=='estimate'){
                EstimateJsonParser objToSave=(EstimateJsonParser)System.JSON.deserialize(res.getBody(), EstimateJsonParser.class);
                quoteObj.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Estimate.Id;
                quoteObj.EstimateNumber__c=objToSave.Estimate.DocNumber;
            }else if(QB_Object_Name=='invoice'){
                MapCustomInvoiceToQuickBookController.InvoiceJsonParser objToSave=(MapCustomInvoiceToQuickBookController.InvoiceJsonParser)System.JSON.deserialize(res.getBody(), MapCustomInvoiceToQuickBookController.InvoiceJsonParser.class);
                quoteObj.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Invoice.Id;
                quoteObj.QB_Balance__c=objToSave.Invoice.Balance;
                quoteObj.EstimateNumber__c=objToSave.Invoice.DocNumber;
            }
            quoteObj.Last_Sync_Date__c=System.now();
            quoteObj.QB_Error__c='';
            
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            quoteObj.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            quoteObj.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Quote Error : '+ErrorToShow);
            QB_Logger.GetLogger('MapInvoiceToQuickBookController').LogError('Quote Sync callout to QB Error(Record - '+quoteObj.id+') : '+ErrorToShow);
        }
        return quoteObj;
    }
    public static string createInvoiceDataJson(String SynchToken,Quote quoteObj,String CompanyId,String Tax_Agency){
        MapCustomInvoiceToQuickBookController.cls_Invoice wrap= new MapCustomInvoiceToQuickBookController.cls_Invoice();
        
        //Custom Fields
        List<MapCustomInvoiceToQuickBookController.cls_CustomField> fieldsWrapperList= new List<MapCustomInvoiceToQuickBookController.cls_CustomField>();
        if(string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c))
        {
            
            MapCustomInvoiceToQuickBookController.CustomFieldsListJson Obj=(MapCustomInvoiceToQuickBookController.CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c, MapCustomInvoiceToQuickBookController.CustomFieldsListJson.class);
            if(!Obj.CustomField.isEmpty()){
                Set<String> CustomFieldSet= new Set<String>();
                For(MapCustomInvoiceToQuickBookController.cls_CustomField str : Obj.CustomField){
                    if(str.StringValue.trim()!=''){
                        CustomFieldSet.add(str.StringValue);
                    }
                }
                List<String> FieldsToQuery = new List<String>();
                FieldsToQuery.addAll(CustomFieldSet);
                if(!CustomFieldSet.isEmpty() && QuickbooksUtility.CheckFieldPermission('quote','isAccessible',FieldsToQuery,False)){
                    //Map fields with actual fields
                    String string_query='select id';
                    For(String str1 : CustomFieldSet){
                        if(str1!='' && !str1.equalsignorecase('Id')){
                            string_query+=','+str1;
                        }
                    }
                    string_query+=' from quote where id=\''+String.escapeSingleQuotes(string.valueOf(quoteObj.Id))+'\'  limit 1';
                    sObject sObj = Database.query(string_query);
                    
                    if(sObj!=Null){
                        For(MapCustomInvoiceToQuickBookController.cls_CustomField str2 : Obj.CustomField){
                            if(String.isNotBlank(str2.StringValue)){
                                MapCustomInvoiceToQuickBookController.cls_CustomField wrapper= new MapCustomInvoiceToQuickBookController.cls_CustomField();
                                
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
        wrap.CustomField=fieldsWrapperList;
        
        //For Line Items
        List<MapCustomInvoiceToQuickBookController.cls_Line> wrapLine= new List<MapCustomInvoiceToQuickBookController.cls_Line>();
        for(QuoteLineItem qli : quoteObj.QuoteLineItems)
        { 
            //For products
            MapCustomInvoiceToQuickBookController.cls_ItemRef ItemRef1 = new MapCustomInvoiceToQuickBookController.cls_ItemRef();
                if(qli.Product2.QB_Id__c!=Null && qli.Product2.QB_Id__c!=''  && (qli.Product2.QB_Id__c.split('-')[0]==CompanyId)){
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
            MapCustomInvoiceToQuickBookController.cls_TaxCodeRef taxobjRef=new MapCustomInvoiceToQuickBookController.cls_TaxCodeRef();
            taxobjRef.value='TAX';
            //For cls_SalesItemLineDetail
            MapCustomInvoiceToQuickBookController.cls_SalesItemLineDetail obj1= new MapCustomInvoiceToQuickBookController.cls_SalesItemLineDetail();
                obj1.ItemRef=ItemRef1;
                obj1.UnitPrice=qli.UnitPrice;
                obj1.Qty=qli.Quantity;
                obj1.ServiceDate=qli.ServiceDate;
                obj1.TaxCodeRef=taxobjRef;
                
            //For Line Object
            MapCustomInvoiceToQuickBookController.cls_Line clsObj= new MapCustomInvoiceToQuickBookController.cls_Line();
                clsObj.LineNum=integer.valueOf(qli.LineNumber);
                clsObj.Amount=qli.Subtotal;
                if(quoteObj.Copy_Line_Item_Description_From__c=='Product')
                    clsObj.Description=qli.Product2.Description;
                else
                    clsObj.Description=qli.Description;
                    
                clsObj.DetailType='SalesItemLineDetail';
                clsObj.SalesItemLineDetail=obj1;
            
            wrapLine.add(clsObj);
        }
        wrap.Line=wrapLine;
        
        //For Opportunity Relation
        MapCustomInvoiceToQuickBookController.cls_CustomerRef cust= new MapCustomInvoiceToQuickBookController.cls_CustomerRef();
            if(quoteObj.opportunity.QB_Id__c!=Null && quoteObj.opportunity.QB_Id__c!=''  && (quoteObj.opportunity.QB_Id__c.split('-')[0]==CompanyId)){
                cust.value=quoteObj.opportunity.QB_Id__c.split('-')[1];
            }else{
                if(OpportunityList.containsKey(quoteObj.opportunityId)){
                    cust.value=OpportunityList.get(quoteObj.opportunityId).QB_Id__c.split('-')[1];
                }else{
                    Opportunity opp=MapOpportunityToQuickBookController.createOppQB(quoteObj.opportunityId);
                    if(opp!=Null && opp.QB_Id__c!=Null){
                        cust.value=opp.QB_Id__c.split('-')[1];
                        OpportunityList.put(opp.Id,opp);
                        if(!MapOpportunityToQuickBookController.isAccountUpdatedMap.isEmpty()){
                            accountList.putAll(MapOpportunityToQuickBookController.isAccountUpdatedMap);
                        }
                    }
                }
            }
        wrap.CustomerRef=cust;
        
        //For Billing Address fields
        MapCustomInvoiceToQuickBookController.cls_BillAddr billAdd= new MapCustomInvoiceToQuickBookController.cls_BillAddr();
            if(quoteObj.BillingName!=Null)
                billAdd.Line1=quoteObj.BillingName.substring(0, Math.min(quoteObj.BillingName.length(), 500));
            if(quoteObj.billingStreet!=Null)
                billAdd.Line2=quoteObj.billingStreet.substring(0, Math.min(quoteObj.billingStreet.length(), 500));
            if(quoteObj.billingState!=Null)
                billAdd.CountrySubDivisionCode=quoteObj.billingState.substring(0, Math.min(quoteObj.billingState.length(), 255));
            if(quoteObj.BillingCity!=Null)
                billAdd.City=quoteObj.BillingCity.substring(0, Math.min(quoteObj.BillingCity.length(), 255));
            if(quoteObj.BillingCountry!=Null)
                billAdd.Country=quoteObj.BillingCountry.substring(0, Math.min(quoteObj.BillingCountry.length(), 255));
            if(quoteObj.BillingPostalCode!=Null)
                billAdd.PostalCode=quoteObj.BillingPostalCode.substring(0, Math.min(quoteObj.BillingPostalCode.length(), 31));

            wrap.BillAddr=billAdd;
        
        MapCustomInvoiceToQuickBookController.cls_ShipAddr shipAdd= new MapCustomInvoiceToQuickBookController.cls_ShipAddr();
            if(quoteObj.ShippingName!=Null)
                shipAdd.Line1=quoteObj.ShippingName.substring(0, Math.min(quoteObj.ShippingName.length(), 500));
            if(quoteObj.ShippingStreet!=Null)
                shipAdd.Line2=quoteObj.ShippingStreet.substring(0, Math.min(quoteObj.ShippingStreet.length(), 500));
            if(quoteObj.ShippingState!=Null)
                shipAdd.CountrySubDivisionCode=quoteObj.ShippingState.substring(0, Math.min(quoteObj.ShippingState.length(), 255));
            if(quoteObj.ShippingCity!=Null)
                shipAdd.City=quoteObj.ShippingCity.substring(0, Math.min(quoteObj.ShippingCity.length(), 255));
            if(quoteObj.ShippingCountry!=Null)
                shipAdd.Country=quoteObj.ShippingCountry.substring(0, Math.min(quoteObj.ShippingCountry.length(), 255));
            if(quoteObj.ShippingPostalCode!=Null)
                shipAdd.PostalCode=quoteObj.ShippingPostalCode.substring(0, Math.min(quoteObj.ShippingPostalCode.length(), 31));
            
            wrap.ShipAddr=shipAdd;
            
        //Shipping info   
        if(String.isNotBlank(quoteObj.QB_Shipping_Method__c)){
            MapCustomInvoiceToQuickBookController.cls_ShipMethodRef shipm=new MapCustomInvoiceToQuickBookController.cls_ShipMethodRef();
            shipm.Value=quoteObj.QB_Shipping_Method__c;
            shipm.Name=quoteObj.QB_Shipping_Method__c;
            wrap.ShipMethodRef=shipm;
        }
        
        wrap.ShipDate=quoteObj.QB_Ship_Date__c;
        wrap.TrackingNum=quoteObj.QB_Shipment_Tracking_Number__c;   
        
        //Sales Terms
        If(quoteObj.Sales_Term__c!=Null){
            MapCustomInvoiceToQuickBookController.cls_SalesTermRef salesTerm=new MapCustomInvoiceToQuickBookController.cls_SalesTermRef();
            if(quoteObj.Sales_Term__r.QB_Id__c!=Null && quoteObj.Sales_Term__r.QB_Id__c!='' && (quoteObj.Sales_Term__r.QB_Id__c.split('-')[0]==CompanyId)){
                    salesTerm.value=quoteObj.Sales_Term__r.QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
            }else{
                if(SalesTermsmap.containsKey(quoteObj.Sales_Term__c)){
                    salesTerm.value=SalesTermsmap.get(quoteObj.Sales_Term__c).QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
                }else{
                    Terms__c Term=MapSalesTermsToQuickBookController.createterm(quoteObj.Sales_Term__c);
                    if(Term!=Null && Term.QB_Id__c!=Null){
                        salesTerm.value=Term.QB_Id__c.split('-')[1];
                        SalesTermsmap.put(Term.Id,Term);
                        wrap.SalesTermRef=salesTerm;
                    }
                }
            }
        }
        
        //Email 
        MapCustomInvoiceToQuickBookController.BillEmail_cls email= new MapCustomInvoiceToQuickBookController.BillEmail_cls();
            email.Address=quoteObj.Email;    
            wrap.BillEmail=email;
        
            if(String.isNotBlank(SynchToken)){
                wrap.Id=quoteObj.QB_Id__c.split('-')[1];
                wrap.SyncToken=SynchToken;
                wrap.sparse=true;
            }
            
            wrap.DueDate=quoteObj.ExpirationDate;
            
            if(quoteObj.Description!=NULL){
                MapCustomInvoiceToQuickBookController.cls_CustomerMemo custMemo= new MapCustomInvoiceToQuickBookController.cls_CustomerMemo();
                custMemo.value=quoteObj.Description.substring(0, Math.min(quoteObj.Description.length(), 1000));
                wrap.CustomerMemo=custMemo;
            }
                
            if(quoteObj.QB_Private_Note__c!=NULL)
                wrap.PrivateNote=quoteObj.QB_Private_Note__c;
            
            wrap.TotalAmt=quoteObj.TotalPrice;
            
            If(quoteObj.QB_Tax_Percent__c!=Null){
                //For TAX
                MapCustomInvoiceToQuickBookController.cls_TaxCodeRef taxobjRef1=new MapCustomInvoiceToQuickBookController.cls_TaxCodeRef();
                taxobjRef1.value=QuickbooksUtility.getTaxCode(quoteObj.QB_Tax_Percent__c,CompanyId,Tax_Agency);
                
                //For TAX field
                MapCustomInvoiceToQuickBookController.cls_TxnTaxDetail taxObj= new MapCustomInvoiceToQuickBookController.cls_TxnTaxDetail();
                //taxObj.TotalTax=quoteObj.Tax;
                taxObj.TxnTaxCodeRef=taxobjRef1;
                //taxObj.TaxLine=cls_TaxLineList;
                
                wrap.TxnTaxDetail=taxObj;
            }else if(quoteObj.Tax!=Null){
                MapCustomInvoiceToQuickBookController.cls_TaxCodeRef taxobjRef1=new MapCustomInvoiceToQuickBookController.cls_TaxCodeRef();
                    taxobjRef1.value=QuickbooksUtility.getTaxCode(0,CompanyId,Tax_Agency);
                
                //For TAX field
                MapCustomInvoiceToQuickBookController.cls_TxnTaxDetail taxObj= new MapCustomInvoiceToQuickBookController.cls_TxnTaxDetail();
                    taxObj.TotalTax=quoteObj.Tax;
                    taxObj.TxnTaxCodeRef=taxobjRef1;
                    
                wrap.TxnTaxDetail=taxObj;
            }
            wrap.TxnDate=quoteObj.Txn_Date__c;
            
            
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    public static string createEstimateDataJson(String SynchToken,Quote quoteObj,String CompanyId,String Tax_Agency){
        cls_Estimate wrap= new cls_Estimate();
        //Custom Fields
        List<cls_CustomField> fieldsWrapperList= new List<cls_CustomField>();
        if(string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuote__c))
        {
            
            CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuote__c, CustomFieldsListJson.class);
            if(!Obj.CustomField.isEmpty()){
                Set<String> CustomFieldSet= new Set<String>();
                For(cls_CustomField str : Obj.CustomField){
                    if(str.StringValue.trim()!=''){
                        CustomFieldSet.add(str.StringValue);
                    }
                }
                List<String> FieldsToQuery = new List<String>();
                FieldsToQuery.addAll(CustomFieldSet);
                if(!CustomFieldSet.isEmpty() && QuickbooksUtility.CheckFieldPermission('quote','isAccessible',FieldsToQuery,False)){
                    //Map fields with actual fields
                    String string_query='select id';
                    For(String str1 : CustomFieldSet){
                        if(str1!='' && !str1.equalsignorecase('Id')){
                            string_query+=','+str1;
                        }
                    }
                    string_query+=' from quote where id=\''+String.escapeSingleQuotes(string.valueOf(quoteObj.Id))+'\'  limit 1';
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
        wrap.CustomField=fieldsWrapperList;
        
        //For Line Items
        List<cls_Line> wrapLine= new List<cls_Line>();
        for(QuoteLineItem qli : quoteObj.QuoteLineItems)
        { 
            //For products
            cls_ItemRef ItemRef1 = new cls_ItemRef();
                if(qli.Product2.QB_Id__c!=Null && qli.Product2.QB_Id__c!=''  && (qli.Product2.QB_Id__c.split('-')[0]==CompanyId)){
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
                clsObj.LineNum=integer.valueOf(qli.LineNumber);
                clsObj.Amount=qli.Subtotal;
                if(quoteObj.Copy_Line_Item_Description_From__c=='Product')
                    clsObj.Description=qli.Product2.Description;
                else
                    clsObj.Description=qli.Description;
                    
                clsObj.DetailType='SalesItemLineDetail';
                clsObj.SalesItemLineDetail=obj1;
            
            wrapLine.add(clsObj);
        }
        wrap.Line=wrapLine;
        
        //For Opportunity Relation
        cls_CustomerRef cust= new cls_CustomerRef();
            if(quoteObj.opportunity.QB_Id__c!=Null && quoteObj.opportunity.QB_Id__c!=''  && (quoteObj.opportunity.QB_Id__c.split('-')[0]==CompanyId)){
                cust.value=quoteObj.opportunity.QB_Id__c.split('-')[1];
            }else{
                if(OpportunityList.containsKey(quoteObj.opportunityId)){
                    cust.value=OpportunityList.get(quoteObj.opportunityId).QB_Id__c.split('-')[1];
                }else{
                    Opportunity opp=MapOpportunityToQuickBookController.createOppQB(quoteObj.opportunityId);
                    if(opp!=Null && opp.QB_Id__c!=Null){
                        cust.value=opp.QB_Id__c.split('-')[1];
                        OpportunityList.put(opp.Id,opp);
                        if(!MapOpportunityToQuickBookController.isAccountUpdatedMap.isEmpty()){
                            accountList.putAll(MapOpportunityToQuickBookController.isAccountUpdatedMap);
                        }
                    }
                }
            }
            wrap.CustomerRef=cust;
        
        //For Billing Address fields
        cls_BillAddr billAdd= new cls_BillAddr();
            if(quoteObj.BillingName!=Null)
                billAdd.Line1=quoteObj.BillingName.substring(0, Math.min(quoteObj.BillingName.length(), 500));
            if(quoteObj.billingStreet!=Null)
                billAdd.Line2=quoteObj.billingStreet.substring(0, Math.min(quoteObj.billingStreet.length(), 500));
            if(quoteObj.billingState!=Null)
                billAdd.CountrySubDivisionCode=quoteObj.billingState.substring(0, Math.min(quoteObj.billingState.length(), 255));
            if(quoteObj.BillingCity!=Null)
                billAdd.City=quoteObj.BillingCity.substring(0, Math.min(quoteObj.BillingCity.length(), 255));
            if(quoteObj.BillingCountry!=Null)
                billAdd.Country=quoteObj.BillingCountry.substring(0, Math.min(quoteObj.BillingCountry.length(), 255));
            if(quoteObj.BillingPostalCode!=Null)
                billAdd.PostalCode=quoteObj.BillingPostalCode.substring(0, Math.min(quoteObj.BillingPostalCode.length(), 31));

            wrap.BillAddr=billAdd;
        
        cls_ShipAddr shipAdd= new cls_ShipAddr();
            if(quoteObj.ShippingName!=Null)
                shipAdd.Line1=quoteObj.ShippingName.substring(0, Math.min(quoteObj.ShippingName.length(), 500));
            if(quoteObj.ShippingStreet!=Null)
                shipAdd.Line2=quoteObj.ShippingStreet.substring(0, Math.min(quoteObj.ShippingStreet.length(), 500));
            if(quoteObj.ShippingState!=Null)
                shipAdd.CountrySubDivisionCode=quoteObj.ShippingState.substring(0, Math.min(quoteObj.ShippingState.length(), 255));
            if(quoteObj.ShippingCity!=Null)
                shipAdd.City=quoteObj.ShippingCity.substring(0, Math.min(quoteObj.ShippingCity.length(), 255));
            if(quoteObj.ShippingCountry!=Null)
                shipAdd.Country=quoteObj.ShippingCountry.substring(0, Math.min(quoteObj.ShippingCountry.length(), 255));
            if(quoteObj.ShippingPostalCode!=Null)
                shipAdd.PostalCode=quoteObj.ShippingPostalCode.substring(0, Math.min(quoteObj.ShippingPostalCode.length(), 31));
            
            wrap.ShipAddr=shipAdd;
            
        //Shipping info   
        if(String.isNotBlank(quoteObj.QB_Shipping_Method__c)){
            cls_ShipMethodRef shipm=new cls_ShipMethodRef();
            shipm.Value=quoteObj.QB_Shipping_Method__c;
            shipm.Name=quoteObj.QB_Shipping_Method__c;
            wrap.ShipMethodRef=shipm;
        }
        
        wrap.ShipDate=quoteObj.QB_Ship_Date__c;
        wrap.TrackingNum=quoteObj.QB_Shipment_Tracking_Number__c;   
        
        //Sales Terms
        If(quoteObj.Sales_Term__c!=Null){
            cls_SalesTermRef salesTerm=new cls_SalesTermRef();
            if(quoteObj.Sales_Term__r.QB_Id__c!=Null && quoteObj.Sales_Term__r.QB_Id__c!='' && (quoteObj.Sales_Term__r.QB_Id__c.split('-')[0]==CompanyId)){
                    salesTerm.value=quoteObj.Sales_Term__r.QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
            }else{
                if(SalesTermsmap.containsKey(quoteObj.Sales_Term__c)){
                    salesTerm.value=SalesTermsmap.get(quoteObj.Sales_Term__c).QB_Id__c.split('-')[1];
                    wrap.SalesTermRef=salesTerm;
                }else{
                    Terms__c Term=MapSalesTermsToQuickBookController.createterm(quoteObj.Sales_Term__c);
                    if(Term!=Null && Term.QB_Id__c!=Null){
                        salesTerm.value=Term.QB_Id__c.split('-')[1];
                        SalesTermsmap.put(Term.Id,Term);
                        wrap.SalesTermRef=salesTerm;
                    }
                }
            }
        }
        
        //Email 
        BillEmail_cls email= new BillEmail_cls();
            email.Address=quoteObj.Email;    
            wrap.BillEmail=email;
        
        if(String.isNotBlank(SynchToken)){
            wrap.Id=quoteObj.QB_Id__c.split('-')[1];
            wrap.SyncToken=SynchToken;
            wrap.sparse=true;
        }
        
        
        wrap.ExpirationDate=quoteObj.ExpirationDate;
        
        if(quoteObj.Description!=NULL){
            cls_CustomerMemo custMemo= new cls_CustomerMemo();
            custMemo.value=quoteObj.Description.substring(0, Math.min(quoteObj.Description.length(), 1000));
            wrap.CustomerMemo=custMemo;
        }
            
        if(quoteObj.QB_Private_Note__c!=NULL)
            wrap.PrivateNote=quoteObj.QB_Private_Note__c;
        
        wrap.TotalAmt=quoteObj.TotalPrice;
        
        If(quoteObj.QB_Tax_Percent__c!=Null){
            //For TAX
            cls_TaxCodeRef taxobjRef1=new cls_TaxCodeRef();
            taxobjRef1.value=QuickbooksUtility.getTaxCode(quoteObj.QB_Tax_Percent__c,CompanyId,Tax_Agency);
            
            //For TAX field
            cls_TxnTaxDetail taxObj= new cls_TxnTaxDetail();
            //taxObj.TotalTax=quoteObj.Tax;
            taxObj.TxnTaxCodeRef=taxobjRef1;
            //taxObj.TaxLine=cls_TaxLineList;
            
            wrap.TxnTaxDetail=taxObj;
        }else if(quoteObj.Tax!=Null){
            cls_TaxCodeRef taxobjRef1=new cls_TaxCodeRef();
                taxobjRef1.value=QuickbooksUtility.getTaxCode(0,CompanyId,Tax_Agency);
            
            //For TAX field
            cls_TxnTaxDetail taxObj= new cls_TxnTaxDetail();
                taxObj.TotalTax=quoteObj.Tax;
                taxObj.TxnTaxCodeRef=taxobjRef1;
                
            wrap.TxnTaxDetail=taxObj;
        }
       
        
        if(string.isNotBlank(quoteObj.QB_Estimate_Status__c))
            wrap.TxnStatus=quoteObj.QB_Estimate_Status__c;
        else
            wrap.TxnStatus=quoteObj.Status;
        
        wrap.TxnDate=quoteObj.Txn_Date__c;
            
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    public PageReference redirectToQuote(){
        PageReference reference=new PageReference('/'+quoteId);
        reference.setRedirect(true);
        return reference;
    }
    
//Wrappers for JSON parsing for Invoice object
   
    public class EstimateJsonParser{
        public cls_Estimate Estimate;
    }
    public class cls_Estimate {
        public String domain;   //QBO
        public boolean sparse;
        public String Id;   //177
        public String SyncToken;    //0
        public cls_MetaData MetaData;
        public cls_CustomField[] CustomField;
        public String DocNumber;    //1001
        public Date TxnDate;    //2015-03-26
        public String TxnStatus;    //Pending
        public cls_Line[] Line;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_CustomerRef CustomerRef;
        public cls_BillAddr BillAddr;
        public cls_ShipAddr ShipAddr;
        public Double TotalAmt; //31.5
        public boolean ApplyTaxAfterDiscount;
        public String PrintStatus;  //NeedToPrint
        public String EmailStatus;  //NotSet
        public BillEmail_cls BillEmail;
        public String AcceptedBy;
        public Date AcceptedDate;
        public Date ExpirationDate;
        public Date DueDate;    //2015-08-23
        public String PrivateNote;
        public cls_CustomerMemo CustomerMemo;
        public String TrackingNum;
        public cls_ShipMethodRef ShipMethodRef;
        public Date ShipDate;
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
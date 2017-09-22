/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapInvoiceCustomFieldsController  {
    public String selectedObject{ get; set; }
    public Boolean isDisabled { get; set; }
    public Boolean IsPaidVersion{ get;set; }
    public QB_Fields_Mapping__c ObjectToMap;
    public QuickBookAuthDetails1__c serviceObject;
    public List<CustomFieldWrapper> fieldsWrapperList{get;set;}
    public String QB_CustomerId;
    public List<SelectOption> fieldsName{get{
        //To show all fields from selected object
        List<SelectOption> fieldsName =new List<SelectOption>();
        fieldsName.add(new SelectOption(' ','None'));
        String SObjectName='';
        if(selectedObject=='Quote' || selectedObject=='QuoteToInvoice')
            SObjectName='Quote';
        else if(selectedObject=='Invoice__c')
            SObjectName='Invoice__c';
            
        String namespacePrefix;
        String[] classNameParts = String.valueOf(MapInvoiceCustomFieldsController.class).split('\\.', 2);
        if(classNameParts.size() > 1 && SObjectName.toLowerCase().endsWith('__c')) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == MapInvoiceCustomFieldsController.class) {
                namespacePrefix = classNameParts[0]+'__';
            } else {
                namespacePrefix = '';
            }
        } else {
            //If there is only one part, the class has no namespace
            namespacePrefix = '';
        }
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(namespacePrefix+SObjectName);
        if (targetType != null) {
            Schema.DescribeSObjectResult typedescription = targetType.getDescribe();
            Map<String, schema.Sobjectfield> fieldMap = typedescription.Fields.getMap();
            
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                fieldsName.add(new SelectOption(dfield.getName(),dfield.getLabel()));
            }
        }
        fieldsName.sort();
        return fieldsName;
    
    }set;}
    
    public MapInvoiceCustomFieldsController() {
        serviceObject = QuickbooksUtility.getServiceSettings();
        ObjectToMap=QuickbooksUtility.getMappingObject();
        isDisabled =true;
        if(serviceObject!=Null){
            IsPaidVersion=serviceObject.Paid_Version__c;
            if(!IsPaidVersion){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Previleges.'));
            }
            getCustomFieldNames();
        }
    }
    
    public PageReference init() {
        //If redirected from SetUp  get all mapping in object
        try{
            String [] FieldsToQuery = new String [] {'Name','QB_Custom_Fields_Mapping__c','QB_Custom_Fields_MappingQuoteInvoice__c','Mapping_Object_Name__c','QB_Custom_Fields_MappingQuote__c','QB_Custom_Fields_MappingInvoice__c'};
            if(serviceObject==Null || !serviceObject.IsSetUpComplete__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not connected to a QuickBooks Account.  Please return to the previous step and connect a QuickBooks account before you map custom fields.  '));
                
            }else if(!QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',Null,True)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',FieldsToQuery,False)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',FieldsToQuery,False)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',Null,True))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
                return null;
            
            }else if(ObjectToMap==Null){
                
                QB_Fields_Mapping__c mappingObject1= new QB_Fields_Mapping__c(Name='Invoice',Mapping_Object_Name__c='Invoice');
                upsert mappingObject1 Mapping_Object_Name__c;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not connect to QuickBooks.  The connection may have timed out.  Please refresh the page and try again. '));
            
            }else if(ObjectToMap!= Null && string.isBlank(ObjectToMap.QB_Custom_Fields_Mapping__c)){
                
                QueryDummyInvoice(serviceObject.Company_Id__c);
                getCustomFieldNames();
            }else{
                getCustomFieldNames();
            }
        }catch(exception e){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
               QB_Logger.GetLogger('MapInvoiceCustomFieldsController').LogError('init', e);
        }
        return null;
    }
    
   public PageReference refreshFromQB() {
        try{
            if(serviceObject==Null || !serviceObject.IsSetUpComplete__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not connected to a QuickBooks Account.  Please return to the previous step and connect a QuickBooks account before you map custom fields.  '));
                return Null;
            }
            //clear existing mapping first
            if(selectedObject=='Quote')
                ObjectToMap.QB_Custom_Fields_MappingQuote__c='';
            else if(selectedObject=='Invoice__c')
                ObjectToMap.QB_Custom_Fields_MappingInvoice__c='';
            else if(selectedObject=='QuoteToInvoice')
                ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c='';
            
            QueryDummyInvoice(serviceObject.Company_Id__c);
            getCustomFieldNames();
            isDisabled=false;
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Fields refreshed successfully.'));
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            QB_Logger.GetLogger('MapInvoiceCustomFieldsController').LogError('refreshFromQB', e);
        }
        return null;
    }

    
    public String QueryDummyInvoice(String CompanyId){
        try{
            
            String queryStr='select%20%2A%20from%20Invoice%20maxresults%201';
            String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/query?query='+queryStr;
         
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
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String, Object>  QueryResponse=(Map<String, Object>)m.get('QueryResponse');
                
                List<Object>  InvoiceList=(List<Object> )QueryResponse.get('Invoice');
                if(InvoiceList!=Null && !InvoiceList.isEmpty()){
                    Map<String, Object> InvoiceListMap=(Map<String, Object>)InvoiceList[0];
                    SaveCustomFields(InvoiceListMap);
                    return Null;
                }else{
                    createDummyInvoice(CompanyId);
                    return Null;
                }
                
            }else{
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error connecting to QuickBooks, Please verify connection setup again.'));
                return Null;
            }
        }catch (System.XMLException e) {  // invalid XML
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                return Null;
        }
    
    }
    
    public void createDummyInvoice(String CompanyId){
    //Create Dummy Account to be used in invoice
    HttpResponse res;
        QB_CustomerId=QueryDummyCustomer(CompanyId);
        
        string reqString='<Invoice xmlns="http://schema.intuit.com/finance/v3"><Line><Amount>0</Amount><Description>Test Invoice</Description><DetailType>DescriptionOnly</DetailType><DescriptionLineDetail><ServiceDate></ServiceDate></DescriptionLineDetail></Line><CustomerRef>'+QB_CustomerId+'</CustomerRef></Invoice>';
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/invoice';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');   
        req.setBody(reqString);
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('content-type', 'application/xml');
        req.setHeader('Accept' , 'application/json');
            
        res = http.send(req); 
     
        if(res.getStatusCode()==200){
        
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object>  m2=(Map<String, Object>)m.get('Invoice');
            SaveCustomFields(m2);
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ErrorToShow));
        }
    }
    
    public String QueryDummyCustomer(String CompanyId){
        String QB_ID='';
        String queryStr='select%20id%20from%20Customer%20where%20givenName%3D%27Test%20Customer%27%20%20maxresults%201';
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/query?query='+queryStr;
     
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
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object>  QueryResponse=(Map<String, Object>)m.get('QueryResponse');
            
            List<Object>  CustomerList=(List<Object> )QueryResponse.get('Customer');
            if(CustomerList!=Null && !CustomerList.isEmpty()){
                Map<String, Object> CustomerMap=(Map<String, Object>)CustomerList[0];
                QB_ID=(String)CustomerMap.get('Id'); 
                return QB_ID;
            }else{
                QB_ID=createDummyCustomer(CompanyId);
                return QB_ID;
            }
            
        }else{
        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error connecting to QuickBooks.'));
            return Null;
        }
    }
    
    public string createDummyCustomer(String CompanyId){
        String QB_ID='';
        string str='<Customer xmlns="http://schema.intuit.com/finance/v3" domain="QBO" sparse="false"><GivenName>Test Customer</GivenName></Customer>';
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/customer';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');   
        req.setBody(str);
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('content-type', 'application/xml');
        req.setHeader('Accept' , 'application/json');
            
        HttpResponse res;
        res = http.send(req); 
        String resParams = res.getBody();
         string outputString = res.getBody();
        if(res.getStatusCode()==200){
            MapOpportunityToQuickBookController.CustomerJsonParserResponse objToSave=(MapOpportunityToQuickBookController.CustomerJsonParserResponse)System.JSON.deserialize(res.getBody(), MapOpportunityToQuickBookController.CustomerJsonParserResponse.class);
            QB_ID=objToSave.Customer.Id;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ErrorToShow));
            return Null;
        }
        return QB_ID;
    }
    
    public void SaveCustomFields(Map<String, Object> m2) {
        try{
            List<Object>  m3=(List<Object>)m2.get('CustomField');
            
            string strJson='{\"CustomField\":[';
            integer i=0;
            for(Object sr : m3){
                Map<String, Object> mapObj=new Map<String, Object>();
                mapObj = (Map<String, Object>)sr;
                if(i>0){
                    strJson+=','; 
                }
                string definationId=string.valueOf(mapObj.get('DefinitionId'));
                string Type=string.valueOf(mapObj.get('Type'));
                string Name=string.valueOf(mapObj.get('Name'));
                strJson+='{\"DefinitionId\":\"'+definationId+'\"'; 
                strJson+=',\"Type\":\"'+Type+'\"'; 
                strJson+=',\"Name\":\"'+Name+'\"'; 
                strJson+=',\"StringValue\":\" \"}';
                i++;
            }
            strJson+=']}';
            
            //Store Custom field JSON Data
            ObjectToMap.Mapping_Object_Name__c='Invoice';
            ObjectToMap.QB_Custom_Fields_Mapping__c=strJson;
            
            upsert ObjectToMap Mapping_Object_Name__c;
            
        }catch(Exception e){
            QB_Logger.GetLogger('MapInvoiceCustomFieldsController').LogError('SaveCustomFields', e);
        }
        
    }
   
    Public List<CustomFieldWrapper> getCustomFieldNames(){
        try{
            if(serviceObject==Null || !serviceObject.IsSetUpComplete__c || ObjectToMap==Null)
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not connected to any QuickBooks Account.'));
                return Null;
            }else{    
                fieldsWrapperList=new List<CustomFieldWrapper>();
                //Get All fields from QB
                if(selectedObject=='Quote' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuote__c)){
                    CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuote__c, CustomFieldsListJson.class);
                    fieldsWrapperList=Obj.CustomField;
                }
                else if(selectedObject=='Invoice__c' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingInvoice__c)){
                    CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingInvoice__c, CustomFieldsListJson.class);
                    fieldsWrapperList=Obj.CustomField;
                }
                else if(selectedObject=='QuoteToInvoice' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c)){
                    CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c, CustomFieldsListJson.class);
                    fieldsWrapperList=Obj.CustomField;
                }
                else if(string.isNotBlank(ObjectToMap.QB_Custom_Fields_Mapping__c))
                {
                    CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_Mapping__c, CustomFieldsListJson.class);
                    fieldsWrapperList=Obj.CustomField;
                }
                return fieldsWrapperList;
            }
        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
             QB_Logger.GetLogger('MapInvoiceCustomFieldsController').LogError('getCustomFieldNames', e);
                return Null;
        }
    }
    
    public PageReference SaveMapping() {
        List<CustomFieldWrapper> CustomfieldsToJson= new List<CustomFieldWrapper>();
        try{
            For(CustomFieldWrapper str : fieldsWrapperList){
            
                CustomFieldWrapper custField= new CustomFieldWrapper();
                
                custField.DefinitionId=str.DefinitionId;
                custField.Type=str.Type;
                custField.Name=str.Name;
                custField.StringValue=str.StringValue;
                
                CustomfieldsToJson.add(custField);
            }
            
            CustomFieldsListJson CFjson= new CustomFieldsListJson();
            CFjson.CustomField=CustomfieldsToJson;
            
            if(selectedObject=='Quote'){
                ObjectToMap.QB_Custom_Fields_MappingQuote__c=Json.serialize(CFjson);
            }
            else if(selectedObject=='Invoice__c'){
                ObjectToMap.QB_Custom_Fields_MappingInvoice__c=Json.serialize(CFjson);
            }
            else if(selectedObject=='QuoteToInvoice'){
                ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c=Json.serialize(CFjson);
            }
            
            upsert ObjectToMap Mapping_Object_Name__c;
            
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Field(s) mapping saved successfully.'));
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            QB_Logger.GetLogger('MapInvoiceCustomFieldsController').LogError('SaveMapping', e);
        }
        isDisabled =true;
        return Null;
    }
    
    public PageReference Cancel() {
        getCustomFieldNames();
        isDisabled =true;
        return null;
    }

    public PageReference editMapping() {
        isDisabled =false;
        return null;
    }
    public PageReference Back() {
        pagereference redirect = new PageReference( '/apex/QuickbooksIntegrationAuth');
        redirect.setRedirect(true);
        return redirect;
    }
    
   //Wrapper for JSON DeSerialisation
   public class CustomFieldsListJson{
        public CustomFieldWrapper[] CustomField{get;set;}
    }
   
    Public class CustomFieldWrapper{
        public String DefinitionId{get;set;} 
        public String Type{get;set;} 
        public String Name{get;set;}
        public string StringValue{get;set;}
        public CustomFieldWrapper(){
        }
    }
}
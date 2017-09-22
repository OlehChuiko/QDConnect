/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
global with sharing class QuickbooksUtility{
    //To get custom setting record for Auth
    public static QuickBookAuthDetails1__c getServiceSettings(){       
        try{
            String [] FieldsToQuery = new String [] {'Name__c','Last_Sync_All_Sf_To_Qb__c','Last_Sync_All_Qb_To_Sf__c','QB_Currency_Name__c','Paid_Version__c','QB_MultiCurrency_Details__c','AutoRunDuration__c','ExpenseAccountRef__c','IncomeAccountRef__c','Tax_Agency__c','ReconnectCronJobId__c','IsSetUpComplete__c','Company_Id__c', 'OAuth_Token__c', 'OAuth_Token_Secret__c', 'Access_Token_URL__c', 'Application_Token__c', 'Authorization_URL__c', 'Consumer_Key__c', 'Consumer_Secret__c', 'Request_Token_URL__c', 'Temporary_Token_Secret__c'};
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isAccessible',FieldsToQuery,False))
            {
                QB_Logger.GetLogger('QuickbooksUtility').LogError('Insufficient access on QuickBookAuthDetails1__c : getServiceSettings');
                return Null;
            }
            List<QuickBookAuthDetails1__c> serviceObject=new List<QuickBookAuthDetails1__c>([Select Name__c,Last_Sync_All_Sf_To_Qb__c,Last_Sync_All_Qb_To_Sf__c,QB_Currency_Name__c,Paid_Version__c,QB_MultiCurrency_Details__c,AutoRunDuration__c,ExpenseAccountRef__c,IncomeAccountRef__c,Tax_Agency__c,ReconnectCronJobId__c,IsSetUpComplete__c,Company_Id__c, OAuth_Token__c, OAuth_Token_Secret__c, Access_Token_URL__c, Application_Token__c, Authorization_URL__c, Consumer_Key__c, Consumer_Secret__c, Request_Token_URL__c, Temporary_Token_Secret__c From QuickBookAuthDetails1__c Where    Name__c='QuickBookAuthDetails' limit 1 ]);
            if(!serviceObject.isEmpty()){
                return serviceObject[0];
            }else{
                return Null;
            }
        } catch(Exception e) {
            QB_Logger.GetLogger('QuickbooksUtility').LogError('getServiceSettings', e);
            return Null;
        }
    }
    //To get custom field mapping record
    public static QB_Fields_Mapping__c getMappingObject(){
        
        try {
            String [] FieldsToQuery = new String [] {'id','QB_Custom_Fields_MappingQuoteInvoice__c','Mapping_Object_Name__c','name','QB_Custom_Fields_Mapping__c','QB_Custom_Fields_MappingInvoice__c','QB_Custom_Fields_MappingQuote__c'};
            if(!QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isAccessible',FieldsToQuery,False))
            {
                QB_Logger.GetLogger('QuickbooksUtility').LogError('Insufficient access : QB_Fields_Mapping__c');
                return Null;
            }
            List<QB_Fields_Mapping__c> mappingObject=new List<QB_Fields_Mapping__c>([select id,QB_Custom_Fields_MappingQuoteInvoice__c,Mapping_Object_Name__c,name,QB_Custom_Fields_Mapping__c,QB_Custom_Fields_MappingInvoice__c,QB_Custom_Fields_MappingQuote__c from QB_Fields_Mapping__c limit 1]);
            if(!mappingObject.isEmpty()){
                return mappingObject[0];
            }else{
                return Null;
            }
        } catch(Exception e) {
            QB_Logger.GetLogger('QuickbooksUtility').LogError('getMappingObject', e);
            return Null;
        }
    }
    
    public static Boolean CheckFieldPermission(String selectedObj,String fieldFilterType,List<String> strSelectedFields,Boolean isObject){
       
        Boolean isSelectedCheck=true;
        map<string,schema.sobjecttype> describe = schema.getglobaldescribe();
        
        String namespacePrefix=QuickbooksUtility.getNameSpacename();
        selectedObj=selectedObj.toLowerCase();  
        if(selectedObj.endsWith('__c'))
        {
            selectedObj=namespacePrefix+selectedObj;
        }
        
        if(describe.containskey(selectedObj) && isObject) {
            if (fieldFilterType=='isCreateable' && !describe.get(selectedObj).getdescribe().isCreateable()) {
                isSelectedCheck= false; 
                QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj);
            }else if(fieldFilterType=='isUpdateable' && !describe.get(selectedObj).getdescribe().isUpdateable()){
                isSelectedCheck= false;
                QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj);             
            }else if(fieldFilterType=='isAccessible' && !describe.get(selectedObj).getdescribe().isAccessible()){
                isSelectedCheck= false; 
                QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj);
            }else if(fieldFilterType=='isDeletable' && !describe.get(selectedObj).getdescribe().isDeletable()){
                isSelectedCheck= false; 
                QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj);
            }

        }else if(describe.containskey(selectedObj) && !isObject && strSelectedFields!=Null && !strSelectedFields.isEmpty()  ){
            
            map<string,schema.sobjectfield> fieldmap = describe.get(selectedObj).getdescribe().fields.getmap();
            
            for (String fieldToCheck : strSelectedFields ) {
                
                fieldToCheck=fieldToCheck.toLowerCase();    
                if(fieldToCheck.endsWith('__c'))
                {
                    fieldToCheck=namespacePrefix+fieldToCheck;
                }
                
                if (fieldFilterType=='isCreateable' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isCreateable()) {
                    isSelectedCheck= false; 
                    QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj+', Field Name -'+fieldToCheck);
                    break;   
                }else if(fieldFilterType=='isUpdateable' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isUpdateable()){
                    isSelectedCheck= false; 
                    QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj+', Field Name -'+fieldToCheck);
                    break; 
                }else if(fieldFilterType=='isAccessible' && fieldmap.containsKey(fieldToCheck) && !fieldmap.get(fieldToCheck).getdescribe().isAccessible()){
                    isSelectedCheck= false; 
                    QB_Logger.GetLogger('QuickbooksUtility').LogError('CheckFieldPermission Method: Insufficient Access on Object Name -'+selectedObj+', Field Name -'+fieldToCheck);
                    break; 
                }
            }
        }
        return isSelectedCheck;
    }
    
    public static String getNameSpacename(){
        String namespacePrefix='';
        String[] classNameParts = String.valueOf(QuickbooksUtility.class).split('\\.', 2);
        if(classNameParts.size() > 1) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == QuickbooksUtility.class) {
                namespacePrefix = classNameParts[0]+'__';
            }
        }
        return namespacePrefix;
    }
   
    public static String readPreferenceObject(String Company_Id){
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+Company_Id+'/preferences/';

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
            QuickbooksUtility.PreferencesJSON objToSave=(QuickbooksUtility.PreferencesJSON)System.JSON.deserialize(res.getBody(), QuickbooksUtility.PreferencesJSON.class);
            String HomeCurrency=objToSave.Preferences.CurrencyPrefs.HomeCurrency.value;
            String IsMultiCurrencyEnabled=string.valueOf(objToSave.Preferences.CurrencyPrefs.MultiCurrencyEnabled);
            return (HomeCurrency+'-'+IsMultiCurrencyEnabled.toUpperCase());
        }else if(res.getStatusCode()==401){
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
        }
        return '';
          
    }
    
    public static String QueryFromQB(String CompanyId,String QueryName,String objName){
        String QB_ID='';
        String queryStr='';
        String objFullyQualifiedName=QueryName;
        
        if(QueryName.contains(':')){
            objFullyQualifiedName='';
            for(String str : QueryName.split(':')){
                objFullyQualifiedName+=str.trim()+':';
            }
            objFullyQualifiedName=objFullyQualifiedName.substring(0, (objFullyQualifiedName.length()-1));
            QueryName=QueryName.split(':')[QueryName.split(':').size()-1].trim();
        }
        
        QueryName = EncodingUtil.urlEncode(QueryName,'UTF-8').replaceAll('\\+','%20').replaceAll('\\*','%2A');
        
        if(objName=='Account' || objName=='Opportunity'){
            queryStr='select%20id%2CFullyQualifiedName%20from%20Customer%20where%20DisplayName%3D%27'+QueryName+'%27%20';
        }else if(objName=='Item'){
            queryStr='select%20%2A%20from%20Item%20where%20Name%3D%27'+QueryName+'%27%20';
        }
        else if(objName=='term'){
            queryStr='select%20id%20from%20Term%20where%20Name%3D%27'+QueryName+'%27%20%20maxresults%201';
        }
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
            if(QueryResponse!=Null){
                List<Object>  CustomerList=new List<Object>();
                if(objName=='Account' || objName=='Opportunity'){
                    CustomerList=(List<Object> )QueryResponse.get('Customer');
                }else if(objName=='Item'){
                    CustomerList=(List<Object> )QueryResponse.get('Item');
                }else if(objName=='term'){
                    CustomerList=(List<Object> )QueryResponse.get('Term');
                    if(CustomerList!=Null && !CustomerList.isEmpty()){
                        Map<String, Object> CustomerMap=(Map<String, Object>)CustomerList[0];
                        QB_ID=(String)CustomerMap.get('Id');
                    }
                    return QB_ID;
                }
                if(CustomerList!=Null && !CustomerList.isEmpty()){
                    for(Object obj :CustomerList){
                        Map<String, Object> CustomerMap=(Map<String, Object>)obj;
                        String FullyQualifiedName=(String)CustomerMap.get('FullyQualifiedName');
                        if(FullyQualifiedName.equalsIgnoreCase(objFullyQualifiedName)){
                            QB_ID=(String)CustomerMap.get('Id');
                            break;
                        }
                    }
                }
            }
        }
        return QB_ID;
    }
    
    public static String readAccount(String CompanyId,String AccountId){
            
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/customer/'+AccountId;

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
            MapOpportunityToQuickBookController.CustomerJsonParserResponse objToSave=(MapOpportunityToQuickBookController.CustomerJsonParserResponse)System.JSON.deserialize(res.getBody(), MapOpportunityToQuickBookController.CustomerJsonParserResponse.class);
            return objToSave.Customer.SyncToken;
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');  
            return null;
            
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            QuickbooksUtility.AddPageMessages(ErrorToShow);  
            return null;
        }
          
    }
    public static String  readInvoice(String CompanyId,String QuoteId,String objName){
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/'+objName+'/'+QuoteId;

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
            if(objName=='estimate'){
                MapInvoiceToQuickBookController.EstimateJsonParser objToSave=(MapInvoiceToQuickBookController.EstimateJsonParser)System.JSON.deserialize(res.getBody(), MapInvoiceToQuickBookController.EstimateJsonParser.class);
                return objToSave.Estimate.SyncToken;
            }else{
                MapCustomInvoiceToQuickBookController.InvoiceJsonParser objToSave=(MapCustomInvoiceToQuickBookController.InvoiceJsonParser)System.JSON.deserialize(res.getBody(), MapCustomInvoiceToQuickBookController.InvoiceJsonParser.class);
                return objToSave.Invoice.SyncToken;
            }
        }else if(res.getStatusCode()==401){
        
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.'); 
            return null;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            QuickbooksUtility.AddPageMessages(ErrorToShow); 
            return null;
        }
    
    }
    //Methods for creating tax Implementation
    public static String getTaxCode(Decimal TaxPercent,String CompanyId,String TaxAgencyCode){
        String queryStr='select%20Id%20from%20TaxCode%20where%20Name%3D%27TaxValue'+TaxPercent+'%27';
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
            
            List<Object>  TaxCodeList=(List<Object> )QueryResponse.get('TaxCode');
            if(TaxCodeList!=Null && !TaxCodeList.isEmpty()){
                Map<String, Object> TaxCodeMap=(Map<String, Object>)TaxCodeList[0];
                String  TaxCodeId=(String)TaxCodeMap.get('Id');
                return TaxCodeId;
            }else{
                String  TaxCodeId=QuickbooksUtility.createNewtTaxCode(TaxPercent,CompanyId,TaxAgencyCode);
                return TaxCodeId;
            }
            
        }else{
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.'); 
            return Null;
        }
    }
    public static String createNewtTaxCode(Decimal TaxPercent,String CompanyId,String TaxAgencyCode){
        String TaxAgencyId='';
        if(String.isBlank(TaxAgencyCode)){
            TaxAgencyId=QuickbooksUtility.createTaxAgency(CompanyId);
        }else{
            TaxAgencyId=TaxAgencyCode;
        }
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/taxservice/taxcode';
        String jsonBody='{"TaxCode":"TaxValue'+TaxPercent+'","TaxRateDetails":[{"TaxRateName":"TaxValue'+TaxPercent+'","RateValue":"'+TaxPercent+'","TaxAgencyId":"'+TaxAgencyId+'","TaxApplicableOn":"Sales"}]}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setBody(jsonBody);
        req.setMethod('POST');   
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('Accept' , 'application/json');
        req.setHeader('content-type', 'application/json');
            
        HttpResponse res;
        res = http.send(req);
        
        if(res.getStatusCode()==200){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            string  TaxCodeId=(string)m.get('TaxCodeId');
            return TaxCodeId;
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.'); 
            return Null;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            QuickbooksUtility.AddPageMessages(ErrorToShow);
            return Null;
        }
    
    }
    public static String createTaxAgency(String CompanyId){
        String  TaxAgencyId;
        try{
            String queryStr='select%20id%20from%20TaxAgency%20maxresults%201';
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
                
                List<Object>  TaxCodeList=(List<Object> )QueryResponse.get('TaxAgency');
                if(TaxCodeList!=Null && !TaxCodeList.isEmpty()){
                    Map<String, Object> TaxCodeMap=(Map<String, Object>)TaxCodeList[0];
                    TaxAgencyId=(String)TaxCodeMap.get('Id');
                    
                }else{
                    TaxAgencyId=QuickbooksUtility.createNewTaxAgency(CompanyId);
                }
                
                return TaxAgencyId;
                
            }else{
                QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
                return Null;
            }
        }catch(Exception e) {
            QuickbooksUtility.AddPageMessages(e.getMessage());  
            QB_Logger.GetLogger('QuickbooksUtility').LogError('createTaxAgency', e);
            return Null;
        }

    }
    public static String createNewTaxAgency(String CompanyId){
         
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/taxagency';
        String jsonBody='{"DisplayName": "CityTaxAgency"}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setBody(jsonBody);
        req.setMethod('POST');   
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('Accept' , 'application/json');
        req.setHeader('content-type', 'application/json');
            
        HttpResponse res;
        res = http.send(req);
        
        if(res.getStatusCode()==200){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object>  TaxAgency=(Map<String, Object>)m.get('TaxAgency');
            string  TaxAgencyId=(string)TaxAgency.get('Id');
            return TaxAgencyId;
        }else if(res.getStatusCode()==401){
        
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            return Null;
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            QuickbooksUtility.AddPageMessages(ErrorToShow);
            return Null;
        }
    
    }
    
    public static HttpResponse makeCalloutToQuickBooks(String endpoint,string reqBody){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');   
        req.setBody(reqBody);
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('Accept' , 'application/json');
        req.setHeader('content-type', 'application/json');
            
        
        HttpResponse res;
        res = http.send(req); 
        
        return res;
    }
    public static string ErrorPageMessage='';
    public static boolean IsCalledFromLightning=false;
    public static void AddPageMessages(String errorMsg){
         if(IsCalledFromLightning && string.isBlank(ErrorPageMessage)){
            ErrorPageMessage=errorMsg;
         }else if(!IsCalledFromLightning && !System.isFuture() && !System.isBatch() &&  !ApexPages.hasMessages(ApexPages.Severity.ERROR)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+errorMsg));
        }
    }
    //For Custom field mapping
    public static String QueryDummyInvoice(String CompanyId,QB_Fields_Mapping__c  ObjectToMap){
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
                    SaveCustomFields(InvoiceListMap,ObjectToMap);
                    return Null;
                }else{
                    createDummyInvoice(CompanyId,ObjectToMap);
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
    
    public static  void createDummyInvoice(String CompanyId,QB_Fields_Mapping__c  ObjectToMap){
    //Create Dummy Account to be used in invoice
    HttpResponse res;
       string  QB_CustomerId=QueryDummyCustomer(CompanyId);
        
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
            SaveCustomFields(m2,ObjectToMap);
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+ErrorToShow));
        }
    }
    
    public static  String QueryDummyCustomer(String CompanyId){
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
            return Null;
        }
    }
    
    public static  string createDummyCustomer(String CompanyId){
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
            return Null;
        }
        return QB_ID;
    }
    public static  void SaveCustomFields(Map<String, Object> m2,QB_Fields_Mapping__c  ObjectToMap) {
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
    }
    //From custom field mapping. code ends
    
    //Wrappers for Error Handling.Code starts
    public class ErrorClass{
        public cls_Fault Fault;
    }
    public class cls_Fault {
        public cls_Error[] Error;
        public String type; //ValidationFault
    }
    public class cls_Error {
        public String Message;  //Stale Object Error
        public String Detail;   //Stale Object Error : You and System Administration were working on this at the same time. System Administration finished before you did, so your work was not saved.
        public String code; //5010
        public String element;  //
    }
    public static ErrorClass parseError(String json){
        return (ErrorClass) System.JSON.deserialize(json, ErrorClass.class);
    }
    
    
    //Request toekn JSON parser wrapper class for QbReconnect
    public class QbReconnectResponseJSON{
        public String OAuthToken;
        public String OAuthTokenSecret;
        public String ErrorMessage; 
        public Integer ErrorCode;   
        public String ServerTime;   
    }
    //Json data wrapper for Preferences
    public class PreferencesJSON{
        public cls_Preferences Preferences;
    }
    public class cls_Preferences {
        public cls_CurrencyPrefs CurrencyPrefs;
    }
    public class cls_CurrencyPrefs {
        public boolean MultiCurrencyEnabled;
        public cls_HomeCurrency HomeCurrency;
    }
    public class cls_HomeCurrency {
        public String value;    //USD
    }
    
    
}
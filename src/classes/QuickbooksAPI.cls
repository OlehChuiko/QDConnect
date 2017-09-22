/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class QuickbooksAPI {

    public String SyncAllQbToSf { get; set; }
    public String SyncAllSfToQb { get; set; }
    public Boolean isPollBatchEnabled { get; set; }
    public void pollBatchRunStatus() {
        QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
        
        if(SyncAllQbToSf=='(In Progress)' && serviceObject1.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject1.Last_Sync_All_Qb_To_Sf__c.year()!=2000){
            SyncAllQbToSf='(Last synced at : '+String.valueOf(serviceObject1.Last_Sync_All_Qb_To_Sf__c.format())+')';
        }
        if(SyncAllSfToQb=='(In Progress)' && serviceObject1.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject1.Last_Sync_All_Sf_To_Qb__c.year()!=2000){
            SyncAllSfToQb='(Last synced at : '+String.valueOf(serviceObject1.Last_Sync_All_Sf_To_Qb__c.format())+')';
        }
        if(SyncAllQbToSf!='(In Progress)' && SyncAllSfToQb!='(In Progress)'){
            isPollBatchEnabled=false;
        }
    }

    public  String currencyDetails{ get;set; }
    public  String multiCurrencyDetails{ get;set; }
    public  String selectedDurationTypeForSchedulers { get;set; }
    public String selectedDurationForSchedulers{ get; set; }
    public string AutoRunInterval { get;set; }
    public List<SelectOption> getAutoRunIntervalList(){
        
        List<SelectOption> fieldsName =new List<SelectOption>();
            fieldsName.add(new SelectOption('','None'));
            fieldsName.add(new SelectOption('45','45'));
            fieldsName.add(new SelectOption('30','30'));
            fieldsName.add(new SelectOption('15','15'));
            fieldsName.add(new SelectOption('10','10'));
        return fieldsName;
    }
    public QuickBookAuthDetails1__c serviceObject;
    public Boolean IsQBConnected{ get;set; }
    public Boolean IsPaidVersion{ get;set; }
    public QuickbooksAPI (){
        try{
            isPollBatchEnabled=false;
            serviceObject=QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null){
                IsQBConnected=serviceObject.IsSetUpComplete__c;
                IsPaidVersion=serviceObject.Paid_Version__c;
                currencyDetails=(String.isBlank(serviceObject.QB_Currency_Name__c) ? '' : serviceObject.QB_Currency_Name__c);
                multiCurrencyDetails=(String.isBlank(serviceObject.QB_MultiCurrency_Details__c) ? '' : serviceObject.QB_MultiCurrency_Details__c);
                
                if(String.isNotBlank(serviceObject.AutoRunDuration__c)){
                    AutoRunInterval=serviceObject.AutoRunDuration__c;
                    
                }
                if(serviceObject.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject.Last_Sync_All_Qb_To_Sf__c.year()==2000){
                    SyncAllQbToSf='(In Progress)';
                }else if(serviceObject.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject.Last_Sync_All_Qb_To_Sf__c.year()!=2000){
                    SyncAllQbToSf='(Last synced at : '+String.valueOf(serviceObject.Last_Sync_All_Qb_To_Sf__c.format())+')';
                }
                if(serviceObject.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject.Last_Sync_All_Sf_To_Qb__c.year()==2000){
                    SyncAllSfToQb='(In Progress)';
                }else if(serviceObject.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject.Last_Sync_All_Sf_To_Qb__c.year()!=2000){
                    SyncAllSfToQb='(Last synced at : '+String.valueOf(serviceObject.Last_Sync_All_Sf_To_Qb__c.format())+')';
                }
                if(SyncAllQbToSf=='(In Progress)' || SyncAllSfToQb=='(In Progress)'){
                    isPollBatchEnabled=true;
                }
            }
        }catch(Exception e){
            QB_Logger.GetLogger('QuickbooksAPI').LogError('QuickbooksAPI', e);
        }
    }
    //For syncing Accounts,opp,Invoice,quotes,Products from salesforce to QuickBooks.
    public pagereference syncAllDataSFToQB(){
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'Last_Sync_All_Sf_To_Qb__c'};
            
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : syncAllDataSFToQB');
                return null;
            }
            serviceObject1.Last_Sync_All_Sf_To_Qb__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
            update serviceObject1;
            
            DataBase.executeBatch(new MapOpportunityToQuickBookBatch(),1);
            isPollBatchEnabled=true;
            SyncAllSfToQb='(In Progress)';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Jobs submitted successfully. Synchronization may take few minutes.')); 
        }catch(Exception e){
            QB_Logger.GetLogger('QuickbooksAPI').LogError('syncAllDataSFToQB', e);
        }
        return null;
    }
    
    //For syncing Invoice,Payments from QuickBooks to salesforce.
    public pagereference syncAllDataQBToSF(){
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'Last_Sync_All_Qb_To_Sf__c'};
            
             if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : syncAllDataQBToSF');
                return null;
            }
            serviceObject1.Last_Sync_All_Qb_To_Sf__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
            update serviceObject1;
            
            //Execute Batch
            DataBase.executeBatch(new QuickBookInvoiceScheduler(),1);
            isPollBatchEnabled=true;
            SyncAllQbToSf='(In Progress)';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Jobs submitted successfully. Synchronization may take few minutes.')); 
        }catch(Exception e){
            QB_Logger.GetLogger('QuickbooksAPI').LogError('syncAllDataQBToSF', e);
        }
        return null;
    }
    
    public pagereference startSchedulers() {
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'AutoRunDuration__c'};
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : startSchedulers');
                return null;
            }
            
                serviceObject.AutoRunDuration__c=AutoRunInterval;
                update serviceObject;
                 
                //Delete existing scheduled batch
                for( CronTrigger c:[Select Id From CronTrigger where CronJobDetail.Name LIKE 'QuickBooksInvoicePaymentScheduler: Running at%']){
                    System.abortJob(c.id);
                }
                
                //Schedule import invoice,payment schedulers
                if(String.isNotBlank(AutoRunInterval)){
                    system.schedule('QuickBooksInvoicePaymentScheduler: Running at 1'+System.now().format(), fetchSchedulerTime(5), new QuickBookInvoiceScheduler());
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Job scheduled successfully.'));
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()));
            QB_Logger.GetLogger('QuickbooksAPI').LogError('startSchedulers', e);
        }
        return null;
    }
    
    //OAuth step 1
    public pagereference OAuth_Step1_getTempTokenAndRedirectToIntuit() {
        try {
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            if(serviceObject!=Null){
               
                String nonce = string.valueof(dateTime.now().getTime()/1000);
                String timestamp = string.valueof(dateTime.now().getTime()/1000);
                
                Map<String,String> parameters = new Map<String,String>();
                parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickbooksIntegrationAuth1', 'UTF-8'));
                parameters.put('oauth_consumer_key', serviceObject.Consumer_Key__c);
                parameters.put('oauth_nonce', nonce);
                parameters.put('oauth_signature_method', 'HMAC-SHA1');
                parameters.put('oauth_timestamp', timestamp);
                parameters.put('oauth_version', '1.0');

                HttpRequest req = new HttpRequest();
                HttpResponse res;
                 
                req.setEndpoint(serviceObject.Request_Token_URL__c);
                req.setMethod('POST'); 
                req.setTimeout(60000);  
                         
                String signature = generateSignature(req, serviceObject.Consumer_Secret__c, '', parameters);
                
                String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickbooksIntegrationAuth1' + '&';
                body += 'oauth_consumer_key=' + serviceObject.Consumer_Key__c + '&';
                body += 'oauth_nonce=' + nonce + '&';
                body += 'oauth_signature_method=HMAC-SHA1&';
                body += 'oauth_timestamp=' + timestamp + '&';
                body += 'oauth_version=1.0&';
                body += 'oauth_signature=' + signature;
                req.setBody(body);
                
                String authToken;
                
                Map<String,String> responseItems = getResponseNVP( req );
                
                String [] FieldsToQuery5 = new String [] {'Temporary_Token_Secret__c'};
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery5,false))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                    QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : OAuth_Step1_getTempTokenAndRedirectToIntuit');
                    return null;
                }
                serviceObject.Temporary_Token_Secret__c = responseItems.get('oauth_token_secret');
                //Update data to Protected custom setting
                update serviceObject;
            
                authToken = responseItems.get('oauth_token');
                
                String redirectUrl = 'https://appcenter.intuit.com/Connect/Begin?oauth_token=' + authToken;
                pagereference redirect = new PageReference( redirectUrl );
                return redirect.setRedirect(true);
            }
        
        } catch(Exception e) {
            QB_Logger.GetLogger('QuickbooksAPI').LogError('OAuth_Step1_getTempTokenAndRedirectToIntuit', e);
            if(e.getMessage().contains('Read timed out'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Could not connect to QuickBooks.  The connection may have timed out.  Please click the Connect to Quickbooks button again.  '));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()));  
            
            
        }
        return Null;
    }
    //OAuth step 2
    public pagereference OAuth_Step2_getFinalToken() {
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String nonce = string.valueof(dateTime.now().getTime()/1000);
            String timestamp = string.valueof(dateTime.now().getTime()/1000);
            
            String tokenParm       = apexpages.currentpage().getparameters().get('oauth_token');
            String tokenVerifier   = apexpages.currentpage().getparameters().get('oauth_verifier');
            String realmId   = apexpages.currentpage().getparameters().get('realmId');
            
            Map<String,String> parameters = new Map<String,String>();
            parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickbooksIntegrationAuth1', 'UTF-8'));
            parameters.put('oauth_consumer_key', serviceObject.Consumer_Key__c);
            parameters.put('oauth_nonce', nonce);
            parameters.put('oauth_signature_method', 'HMAC-SHA1');
            parameters.put('oauth_timestamp', timestamp);
            parameters.put('oauth_token', tokenParm);
            parameters.put('oauth_verifier', tokenVerifier);
            parameters.put('oauth_version', '1.0');
        
            Http http       = new Http();
            HttpRequest req = new HttpRequest();
             
            req.setEndpoint(serviceObject.Access_Token_URL__c);
            req.setMethod('POST');  
            req.setTimeout(60000); 
                     
            String signature = generateSignature(req, serviceObject.Consumer_Secret__c, serviceObject.Temporary_Token_Secret__c, parameters);
            
            String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickbooksIntegrationAuth1' + '&';
            body += 'oauth_consumer_key=' + serviceObject.Consumer_Key__c + '&';
            body += 'oauth_nonce=' + nonce + '&';
            body += 'oauth_signature_method=HMAC-SHA1&';
            body += 'oauth_timestamp=' + timestamp + '&';
            body += 'oauth_version=1.0&';
            body += 'oauth_token=' + tokenParm + '&';
            body += 'oauth_verifier=' + tokenVerifier + '&';
            body += 'oauth_signature=' + signature;     
            req.setBody(body);

            Map<String,String> responseItems = getResponseNVP( req );
        
            serviceObject.OAuth_Token__c = responseItems.get('oauth_token');
            serviceObject.OAuth_Token_Secret__c = responseItems.get('oauth_token_secret');
            serviceObject.Company_Id__c =realmId;
            serviceObject.Last_Token_Refresh_Date__c=Date.Today();
            if(string.isNotBlank(serviceObject.OAuth_Token__c) && string.isNotBlank(serviceObject.OAuth_Token_Secret__c)){
                serviceObject.IsSetUpComplete__c=true;
            }
            
            //Schedule job to refresh token between 150-180 Days window.Code Starts
            if(String.isNotBlank(serviceObject.ReconnectCronJobId__c)){
                for( CronTrigger c:[Select Id From CronTrigger where id =:serviceObject.ReconnectCronJobId__c]){
                    System.abortJob(c.id);
                }
                serviceObject.ReconnectCronJobId__c='';
            }
           
            Date dt= Date.Today().addDays(160);
            String day = string.valueOf(dt.day());
            String month = string.valueOf(dt.month());
            String year = string.valueOf(dt.year());
            
            String strJobName = 'QBReconnectJob-' +day+ '_' + month + '_' + year;
            String strSchedule = '0 ' + 0 + ' ' + 1 + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            
            serviceObject.ReconnectCronJobId__c=System.schedule(strJobName ,strSchedule, new ReconnectApiScheduledClass());
            //Schedule job to refresh token between 150-180 Days window.Code ends
            
            
            String [] FieldsToQuery = new String [] {'ReconnectCronJobId__c','OAuth_Token__c','OAuth_Token_Secret__c','Company_Id__c','Last_Token_Refresh_Date__c','IsSetUpComplete__c'};
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : OAuth_Step2_getFinalToken');
                return null;
            }
            //Update data to Protected custom setting
            update serviceObject;
            
            String redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QuickBooksAuthComplete';
            pagereference redirect = new PageReference( redirectUrl );
            redirect.setRedirect(true);
            return redirect;
        
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()));
            QB_Logger.GetLogger('QuickbooksAPI').LogError('OAuth_Step2_getFinalToken', e);
            return Null;
        }
    }
   
    public PageReference disconnectQB() {
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'Last_Token_Refresh_Date__c,OAuth_Token__c','OAuth_Token_Secret__c','IsSetUpComplete__c','Company_Id__c','Tax_Agency__c','Temporary_Token_Secret__c','ExpenseAccountRef__c','IncomeAccountRef__c','AutoRunDuration__c','QB_Currency_Name__c','QB_MultiCurrency_Details__c','Last_Sync_All_Qb_To_Sf__c','Last_Sync_All_Sf_To_Qb__c'};
            String [] FieldsToQuery2 = new String [] {'QB_Custom_Fields_Mapping__c','QB_Custom_Fields_MappingInvoice__c','QB_Custom_Fields_MappingQuote__c','QB_Custom_Fields_MappingQuoteInvoice__c'};
            
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) 
                || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.')); 
                QB_Logger.GetLogger('OAuth_Step1_getTempTokenAndRedirectToIntuit').LogError('Insufficient access on QuickBookAuthDetails1__c or QB_Fields_Mapping__c : disconnectQB');
                return null;
            }
            //Update Custom setting
            serviceObject.Last_Token_Refresh_Date__c=Null;
            serviceObject.OAuth_Token__c='';
            serviceObject.OAuth_Token_Secret__c='';
            serviceObject.IsSetUpComplete__c=false;
            serviceObject.Company_Id__c='';
            serviceObject.Tax_Agency__c='';
            serviceObject.Temporary_Token_Secret__c='';
            serviceObject.ExpenseAccountRef__c='';
            serviceObject.IncomeAccountRef__c='';
            serviceObject.AutoRunDuration__c='';
            serviceObject.QB_Currency_Name__c='';
            serviceObject.QB_MultiCurrency_Details__c='';
            serviceObject.Last_Sync_All_Qb_To_Sf__c=null;
            serviceObject.Last_Sync_All_Sf_To_Qb__c=null;
            
            for( CronTrigger c:[Select Id From CronTrigger where id =:serviceObject.ReconnectCronJobId__c OR CronJobDetail.Name LIKE 'QuickBooksInvoicePaymentScheduler: Running at%' /*OR CronJobDetail.Name LIKE 'QuickBookSyncAllDataScheduler: Running at%'*/]){
                System.abortJob(c.id);
            }
            serviceObject.ReconnectCronJobId__c='';
            
            //Update data to Protected custom setting
            update serviceObject;
            
            //Delete Custom Field Mappings
            QB_Fields_Mapping__c mappingObject=QuickbooksUtility.getMappingObject();
            if(mappingObject!=Null){
                mappingObject=QuickbooksUtility.getMappingObject();
                mappingObject.QB_Custom_Fields_Mapping__c='';
                mappingObject.QB_Custom_Fields_MappingInvoice__c='';
                mappingObject.QB_Custom_Fields_MappingQuote__c='';
                mappingObject.QB_Custom_Fields_MappingQuoteInvoice__c='';
                update mappingObject;
            }
            
            IsQBConnected=false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Quickbooks account disconnected.')); 
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage())); 
            QB_Logger.GetLogger('QuickbooksAPI').LogError('disconnectQB', e);
        }
        return null;
    }
    
    public PageReference mapQBFieldPage() {
        pagereference redirect = new PageReference('/apex/MapInvoiceCustomFields');
        redirect.setRedirect(true);
        return redirect;
    }
    public PageReference createTaxAgency() {
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'QB_Currency_Name__c','QB_MultiCurrency_Details__c','Tax_Agency__c'};
            
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : createTaxAgency');
                return null;
            }
            //Get QB currency details And Create Tax Agency.Code Starts
            String currencyDetails=QuickbooksUtility.readPreferenceObject(serviceObject.Company_Id__c);
            if(String.isNotBlank(currencyDetails) && currencyDetails.contains('-')){
                serviceObject.QB_Currency_Name__c='QuickBooks Home Currency - '+currencyDetails.split('-')[0];
                serviceObject.QB_MultiCurrency_Details__c='QuickBooks Multi Currency Enabled - '+currencyDetails.split('-')[1];
            }
            string TaxAgencyId=QuickbooksUtility.createTaxAgency(serviceObject.Company_Id__c);
            serviceObject.Tax_Agency__c= TaxAgencyId;
            
            //Update data to Protected custom setting
            update serviceObject;
        }catch(Exception e) {
            QB_Logger.GetLogger('QuickbooksAPI').LogError('createTaxAgency', e);
        }
        return null;
    }

    public static HttpRequest signRequest(HttpRequest req) {
        QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();

        String nonce     = string.valueof(dateTime.now().getTime()/1000);
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
 
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', serviceObject.Consumer_Key__c);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', EncodingUtil.urlEncode(serviceObject.OAuth_Token__c, 'UTF-8'));
        parameters.put('oauth_version', '1.0');
 
        String signature = generateSignature(req, serviceObject.Consumer_Secret__c, serviceObject.OAuth_Token_Secret__c, parameters);
        String header = generateHeader(signature, parameters);
        req.setHeader('Authorization', header);
 
        return req;
    }

    public static String generateHeader(String signature, Map<String,String> parameters) {
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header + key + '="'+parameters.get(key)+'", ';
        }
        return header + 'oauth_signature="' + signature + '"';
    }
 
    public static String generateSignature(HttpRequest req, String consumerSecret, String tokenSecret, Map<String,String> parameters) {
        String s    = createBaseString(req, parameters);        
        String key  = EncodingUtil.urlEncode(consumerSecret, 'UTF-8') + '&' + EncodingUtil.urlEncode(tokenSecret, 'UTF-8');
 
        Blob sig = Crypto.generateMac(
           'HmacSHA1'
          , Blob.valueOf(s)
          , Blob.valueOf(key)
        );
        return EncodingUtil.urlEncode( EncodingUtil.base64encode(sig), 'UTF-8');
    }
 
    public static String createBaseString(HttpRequest req, Map<String,String> parameters) {
        Map<String,String> p = parameters.clone();
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
 
        return req.getMethod().toUpperCase()+ '&' +
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
 

    public  static Map<String,String> getUrlParams(String value) {
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                res.put(kv[0],kv[1]);
            }
        }
        return res;
    }
    
    public static Map<String,String> getResponseNVP(HttpRequest req){
        
        Http http = new Http();
        HttpResponse res;

        res = http.send(req); 
        String resParams = res.getBody();
            
        Map<String,String> rp = new Map<String,String>();
        
        for(String s : resParams.split('&')) {
            List<String> kv = s.split('=');
            rp.put(kv[0],kv[1]);
        }
        return rp;
    }
    //Get QB currency details.
    public pagereference refreshCurrencyDetails(){
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'QB_Currency_Name__c','QB_MultiCurrency_Details__c'};
            
            if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QuickbooksAPI').LogError('Insufficient access on QuickBookAuthDetails1__c : refreshCurrencyDetails');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Insufficient access.'));
                return null;
            }
            
            String currencyDetails=QuickbooksUtility.readPreferenceObject(serviceObject.Company_Id__c);
            if(String.isNotBlank(currencyDetails) && currencyDetails.contains('-')){
                serviceObject.QB_Currency_Name__c='QuickBooks Home Currency - '+currencyDetails.split('-')[0];
                serviceObject.QB_MultiCurrency_Details__c='QuickBooks Multi Currency Enabled - '+currencyDetails.split('-')[1];
                currencyDetails=serviceObject.QB_Currency_Name__c;
                multiCurrencyDetails=serviceObject.QB_MultiCurrency_Details__c;
            }
            //Update data to Protected custom setting
            update serviceObject;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Currency details refreshed successfully.'));
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,+e.getMessage()));  
            QB_Logger.GetLogger('QuickbooksAPI').LogError('refreshCurrencyDetails', e);
        }
        return null;
        
    }
    
    public string fetchSchedulerTime(Integer minutes) {
        dateTime dt=System.now().addMinutes(minutes);
        String Csec,Cmin,Chr,Cday,Cmonth,CYear;
        Csec=String.valueof(dt.second());
        Cmin=String.valueof(dt.minute());
        Chr=String.valueof(dt.hour());
        Cday=String.valueof(dt.day());
        Cmonth=String.valueof(dt.month());
        CYear=String.valueof(dt.Year());
        
        String SchTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
        return SchTimer;
    }
    
    public PageReference Back() {
        pagereference redirect = new PageReference( '/apex/QuickbooksIntegrationAuth');
        redirect.setRedirect(true);
        return redirect;
    }
}
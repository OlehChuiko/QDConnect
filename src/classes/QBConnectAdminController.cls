/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
global with sharing class QBConnectAdminController {
    @AuraEnabled
    global static string InitMethod(string authStep,string tokenParm,string tokenVerifier,string realmId){
		RemoteSaveResult wrap=new RemoteSaveResult();
		
		if(authStep=='2'){
			//Call auth step 2 method here
			wrap=OAuth_Step2_getFinalToken(tokenParm,tokenVerifier,realmId);
			
		}else if(authStep=='3'){
			//Call auth complete step 3 method here
			wrap=createTaxAgency();
			
		}else{
			//Normal Page Load functions
			wrap=loadAllData();
		}
		return Json.serialize(wrap);
    }
    public static RemoteSaveResult loadAllData(){
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            wrap.isPollBatchEnabled=false;
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null){
                wrap.IsQBConnected=serviceObject.IsSetUpComplete__c;
                wrap.currencyDetails=(String.isBlank(serviceObject.QB_Currency_Name__c) ? '' : serviceObject.QB_Currency_Name__c);
                wrap.multiCurrencyDetails=(String.isBlank(serviceObject.QB_MultiCurrency_Details__c) ? '' : serviceObject.QB_MultiCurrency_Details__c);
                
                if(String.isNotBlank(serviceObject.AutoRunDuration__c)){
                    wrap.AutoRunInterval=serviceObject.AutoRunDuration__c;
                    
                }
                if(serviceObject.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject.Last_Sync_All_Qb_To_Sf__c.year()==2000){
                    wrap.SyncAllQbToSf='(In Progress)';
                }else if(serviceObject.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject.Last_Sync_All_Qb_To_Sf__c.year()!=2000){
                    wrap.SyncAllQbToSf='(Last synced at : '+String.valueOf(serviceObject.Last_Sync_All_Qb_To_Sf__c.format())+')';
                }
                if(serviceObject.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject.Last_Sync_All_Sf_To_Qb__c.year()==2000){
                    wrap.SyncAllSfToQb='(In Progress)';
                }else if(serviceObject.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject.Last_Sync_All_Sf_To_Qb__c.year()!=2000){
                    wrap.SyncAllSfToQb='(Last synced at : '+String.valueOf(serviceObject.Last_Sync_All_Sf_To_Qb__c.format())+')';
                }
                if(wrap.SyncAllQbToSf=='(In Progress)' || wrap.SyncAllSfToQb=='(In Progress)'){
                    wrap.isPollBatchEnabled=true;
                }
            }
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('InitMethod', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
    }
    @AuraEnabled
    global static string OAuth_Step1_getTempTokenAndRedirectToIntuit() {
        RemoteSaveResult wrap=new RemoteSaveResult();
        try {
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            if(serviceObject!=Null){
                
                String nonce = string.valueof(dateTime.now().getTime()/1000);
                String timestamp = string.valueof(dateTime.now().getTime()/1000);
                
                Map<String,String> parameters = new Map<String,String>();
                parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QB_Connect_Admin?authStep=2', 'UTF-8'));
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
                
                String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QB_Connect_Admin?authStep=2' + '&';
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
                    QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : OAuth_Step1_getTempTokenAndRedirectToIntuit');
					wrap.success=false;
					wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c';
					
					return Json.serialize(wrap);
                }
                serviceObject.Temporary_Token_Secret__c = responseItems.get('oauth_token_secret');
                
                //Update data to Protected custom setting
                update serviceObject;
                
                authToken = responseItems.get('oauth_token');
                
                wrap.success=true;
                wrap.errorMessage=null;
                wrap.authToken=authToken;
                
            }
            
        } catch(Exception e) {
            QB_Logger.GetLogger('QBConnectAdminController').LogError('OAuth_Step1_getTempTokenAndRedirectToIntuit', e);
            if(e.getMessage().contains('Read timed out')){
                wrap.success=false;
                wrap.errorMessage='Could not connect to QuickBooks.  The connection may have timed out.  Please click the Connect to Quickbooks button again.  ';
            }else{
                wrap.success=false;
                wrap.errorMessage=e.getMessage();  
            }
            
        }
        return Json.serialize(wrap);
    }
    //OAuth step 2
    public static RemoteSaveResult OAuth_Step2_getFinalToken(String tokenParm,String tokenVerifier,String realmId) {
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String nonce = string.valueof(dateTime.now().getTime()/1000);
            String timestamp = string.valueof(dateTime.now().getTime()/1000);
            
            Map<String,String> parameters = new Map<String,String>();
            parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QB_Connect_Admin?authStep=2', 'UTF-8'));
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
            
            String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/QB_Connect_Admin?authStep=2' + '&';
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
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : OAuth_Step2_getFinalToken');
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c.';
                return wrap;
            }
            //Update data to Protected custom setting
            update serviceObject;
            
            wrap.success=true;
            wrap.errorMessage=null;
            
        } catch(Exception e) {
            QB_Logger.GetLogger('QBConnectAdminController').LogError('OAuth_Step2_getFinalToken', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage(); 
        }
        return wrap;
    }
    
    @AuraEnabled
    global static string disconnectQB() {
        RemoteSaveResult wrap=new RemoteSaveResult();
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
                    wrap.success=false;
                    wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c or QB_Fields_Mapping__c'; 
                    QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c or QB_Fields_Mapping__c : disconnectQB');
                    return Json.serialize(wrap);
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
            
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e) {
            QB_Logger.GetLogger('QBConnectAdminController').LogError('disconnectQB', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    //Get QB currency details.
    @AuraEnabled
    global static string refreshCurrencyDetails(){
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'QB_Currency_Name__c','QB_MultiCurrency_Details__c'};
                
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                   || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : refreshCurrencyDetails');
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c';
            }
            
            String currencyDetails=QuickbooksUtility.readPreferenceObject(serviceObject.Company_Id__c);
            if(String.isNotBlank(currencyDetails) && currencyDetails.contains('-')){
                serviceObject.QB_Currency_Name__c='QuickBooks Home Currency - '+currencyDetails.split('-')[0];
                serviceObject.QB_MultiCurrency_Details__c='QuickBooks Multi Currency Enabled - '+currencyDetails.split('-')[1];
                
                wrap.currencyDetails=serviceObject.QB_Currency_Name__c;
                wrap.multiCurrencyDetails=serviceObject.QB_MultiCurrency_Details__c;
            }
            //Update data to Protected custom setting
            update serviceObject;
            
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e) {
            QB_Logger.GetLogger('QBConnectAdminController').LogError('refreshCurrencyDetails', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
        
    }
    @AuraEnabled
    global static string  startSchedulers(string AutoRunInterval) {
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'AutoRunDuration__c'};
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : startSchedulers');
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c';
                return Json.serialize(wrap);
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
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('startSchedulers', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    
    //For syncing Accounts,opp,Invoice,quotes,Products from salesforce to QuickBooks.
    @AuraEnabled
    global static string  syncAllDataSFToQB(){
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'Last_Sync_All_Sf_To_Qb__c'};
                
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : syncAllDataSFToQB');
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c';
                return Json.serialize(wrap);
            }
            serviceObject1.Last_Sync_All_Sf_To_Qb__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
            update serviceObject1;
            
            DataBase.executeBatch(new MapOpportunityToQuickBookBatch(),1);
            wrap.isPollBatchEnabled=true;
            wrap.SyncAllSfToQb='(In Progress)';
            
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('syncAllDataSFToQB', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    
    //For syncing Invoice,Payments from QuickBooks to salesforce.
    @AuraEnabled
    global static string  syncAllDataQBToSF(){
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'Last_Sync_All_Qb_To_Sf__c'};
                
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : syncAllDataQBToSF');
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c';
                return Json.serialize(wrap);
            }
            serviceObject1.Last_Sync_All_Qb_To_Sf__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
            update serviceObject1;
            
            //Execute Batch
            DataBase.executeBatch(new QuickBookInvoiceScheduler(),1);
            wrap.isPollBatchEnabled=true;
            wrap.SyncAllQbToSf='(In Progress)';
            
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('syncAllDataQBToSF', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    
    @AuraEnabled
    global static string  pollBatchRunStatus(string SyncAllQbToSf,string SyncAllSfToQb) {
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            QuickBookAuthDetails1__c serviceObject1=QuickbooksUtility.getServiceSettings();
            
            wrap.isPollBatchEnabled=true;
            wrap.SyncAllQbToSf=SyncAllQbToSf;
            wrap.SyncAllSfToQb=SyncAllSfToQb;
            
            if(wrap.SyncAllQbToSf=='(In Progress)' && serviceObject1.Last_Sync_All_Qb_To_Sf__c!=Null && serviceObject1.Last_Sync_All_Qb_To_Sf__c.year()!=2000){
                wrap.SyncAllQbToSf='(Last synced at : '+String.valueOf(serviceObject1.Last_Sync_All_Qb_To_Sf__c.format())+')';
            }
            if(wrap.SyncAllSfToQb=='(In Progress)' && serviceObject1.Last_Sync_All_Sf_To_Qb__c!=Null && serviceObject1.Last_Sync_All_Sf_To_Qb__c.year()!=2000){
                wrap.SyncAllSfToQb='(Last synced at : '+String.valueOf(serviceObject1.Last_Sync_All_Sf_To_Qb__c.format())+')';
            }
            if(wrap.SyncAllQbToSf!='(In Progress)' && wrap.SyncAllSfToQb!='(In Progress)'){
                wrap.isPollBatchEnabled=false;
            }
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('pollBatchRunStatus', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    
    @AuraEnabled
    global static string refreshFromQB(string selectedObject) {
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            QuickBookAuthDetails1__c  serviceObject = QuickbooksUtility.getServiceSettings();
            QB_Fields_Mapping__c  ObjectToMap=QuickbooksUtility.getMappingObject();
            if(serviceObject==Null || !serviceObject.IsSetUpComplete__c)
            {
                wrap.success=false;
                wrap.errorMessage='You are not connected to a QuickBooks Account. Please return to the previous step and connect a QuickBooks account before you map custom fields.';
                wrap.CustomField=null;
                
                return Json.serialize(wrap);
            }
            //clear existing mapping first
            ObjectToMap.QB_Custom_Fields_MappingQuote__c='';
            ObjectToMap.QB_Custom_Fields_MappingInvoice__c='';
            
            ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c='';
            
            ObjectToMap.QB_Custom_Fields_Mapping__c='';
            
            string fieldsResponse=getCustomFieldNames(selectedObject,ObjectToMap);
            system.debug('fieldsResponse-----------'+fieldsResponse);
            return fieldsResponse;
        }catch(exception e){
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
            wrap.CustomField=null;
            QB_Logger.GetLogger('QBConnectAdminController').LogError('refreshFromQB', e);
            
            return Json.serialize(wrap);
        }
    }
    
    @AuraEnabled
    global static string getCustomFieldNames(string selectedObject,QB_Fields_Mapping__c  ObjectToMap){
        
        RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            QuickBookAuthDetails1__c  serviceObject = QuickbooksUtility.getServiceSettings();
            system.debug('here is flow-----------'+ObjectToMap);
            if(ObjectToMap==null){
                ObjectToMap=QuickbooksUtility.getMappingObject();
            }
            
            String [] FieldsToQuery = new String [] {'Name','QB_Custom_Fields_Mapping__c','QB_Custom_Fields_MappingQuoteInvoice__c','Mapping_Object_Name__c','QB_Custom_Fields_MappingQuote__c','QB_Custom_Fields_MappingInvoice__c'};
                if(serviceObject==Null || !serviceObject.IsSetUpComplete__c)
            {
                wrap.success=false;
                wrap.errorMessage='You are not connected to a QuickBooks Account. Please return to the previous step and connect a QuickBooks account before you map custom fields.';
                wrap.CustomField=null;
                return Json.serialize(wrap);
            }else if(!QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',Null,True)
                     || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',FieldsToQuery,False)
                     || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',FieldsToQuery,False)
                     || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',Null,True))
            {
                wrap.success=false;
                wrap.errorMessage='Insufficient access on QB_Fields_Mapping__c';
                wrap.CustomField=null;
                return Json.serialize(wrap); 
                
            }else if(ObjectToMap==Null){
                
                QB_Fields_Mapping__c mappingObject1= new QB_Fields_Mapping__c(Name='Invoice',Mapping_Object_Name__c='Invoice');
                upsert mappingObject1 Mapping_Object_Name__c;
                
                wrap.success=false;
                wrap.errorMessage='Could not connect to QuickBooks.  The connection may have timed out.  Please refresh the page and try again. ';
                wrap.CustomField=null;   
                return Json.serialize(wrap);
                
            }else if(ObjectToMap!= Null && string.isBlank(ObjectToMap.QB_Custom_Fields_Mapping__c)){
                QuickbooksUtility.QueryDummyInvoice(serviceObject.Company_Id__c,ObjectToMap);
            }                
            //Get All fields from QB
            if(selectedObject=='Quote' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuote__c)){
                CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuote__c, CustomFieldsListJson.class);
                wrap.CustomField=Obj.CustomField;
            }
            else if(selectedObject=='Invoice__c' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingInvoice__c)){
                CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingInvoice__c, CustomFieldsListJson.class);
                wrap.CustomField=Obj.CustomField;
            }
            else if(selectedObject=='QuoteToInvoice' && string.isNotBlank(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c)){
                CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_MappingQuoteInvoice__c, CustomFieldsListJson.class);
                wrap.CustomField=Obj.CustomField;
            }
            else if(string.isNotBlank(ObjectToMap.QB_Custom_Fields_Mapping__c))
            {
                CustomFieldsListJson Obj=(CustomFieldsListJson) System.JSON.deserialize(ObjectToMap.QB_Custom_Fields_Mapping__c, CustomFieldsListJson.class);
                wrap.CustomField=Obj.CustomField;
            }
            
            wrap.success=true;
            wrap.errorMessage=null; 
            
        }catch(Exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('getCustomFieldNames', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
            wrap.CustomField=null;
        }
        return Json.serialize(wrap);
    }
    @AuraEnabled
    global static map<string,List<SelectOptionClass>> fetchAllSfFields(){
        
        map<string,List<SelectOptionClass>> ResultMap=new map<string,List<SelectOptionClass>>();
        List<String> AllObjectsList = new List<String>{'Quote','Invoice__c','QuoteToInvoice'};
            
            
            for(String selectedObject : AllObjectsList){
                List<SelectOptionClass> fieldsName = new List<SelectOptionClass>();
                List<SelectOptionClass> fieldsName1 = new List<SelectOptionClass>();
                
                fieldsName.add(new SelectOptionClass('None',''));
                
                string SObjectName='';
                if(selectedObject=='Quote' || selectedObject=='QuoteToInvoice')
                    SObjectName='Quote';
                else if(selectedObject=='Invoice__c')
                    SObjectName='Invoice__c';
                
                String namespacePrefix;
                String[] classNameParts = String.valueOf(QBConnectAdminController.class).split('\\.', 2);
                if(classNameParts.size() > 1 && SObjectName.toLowerCase().endsWith('__c')) {
                    Type classType = Type.forName(classNameParts[0], classNameParts[1]);
                    if(classType == QBConnectAdminController.class) {
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
                        fieldsName1.add(new SelectOptionClass(dfield.getLabel(),dfield.getName()));
                    }
                }
                fieldsName1.sort();
                fieldsName.addAll(fieldsName1);
                
                ResultMap.put(selectedObject,fieldsName);
            }
        return ResultMap;
        
    }
    @AuraEnabled
    global static string SaveMapping(string selectedObject,string fieldsWrapperListJSON) {
        RemoteSaveResult wrap=new RemoteSaveResult();
        List<CustomFieldWrapper> CustomfieldsToJson= new List<CustomFieldWrapper>();
        try{
            QB_Fields_Mapping__c  ObjectToMap=QuickbooksUtility.getMappingObject();
            List<CustomFieldWrapper> fieldsWrapperList = (List<CustomFieldWrapper>)JSON.deserialize(fieldsWrapperListJSON, List<CustomFieldWrapper>.class);
            
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
            
            wrap.success=true;
            wrap.errorMessage=null;
        }catch(exception e){
            QB_Logger.GetLogger('QBConnectAdminController').LogError('SaveMapping', e);
            wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return Json.serialize(wrap);
    }
    public static RemoteSaveResult createTaxAgency() {
		RemoteSaveResult wrap=new RemoteSaveResult();
        try{
            //Get data from Protected custom setting
            QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
            
            String [] FieldsToQuery = new String [] {'QB_Currency_Name__c','QB_MultiCurrency_Details__c','Tax_Agency__c'};
                
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                   || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false))
            {
                QB_Logger.GetLogger('QBConnectAdminController').LogError('Insufficient access on QuickBookAuthDetails1__c : createTaxAgency');
                wrap.success=false;
				wrap.errorMessage='Insufficient access on QuickBookAuthDetails1__c.';
				
				return wrap;
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
			
			wrap.success=true;
            wrap.errorMessage=null;
        }catch(Exception e) {
            QB_Logger.GetLogger('QBConnectAdminController').LogError('createTaxAgency', e);
			wrap.success=false;
            wrap.errorMessage=e.getMessage();
        }
        return wrap;
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
    public static string fetchSchedulerTime(Integer minutes) {
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
    
    //Wrapper for JSON DeSerialisation
    
    global class RemoteSaveResult {
        public Boolean success;
        public String errorMessage;
        
        public String authToken;
        public Boolean IsQBConnected;
        public String SyncAllQbToSf;
        public String SyncAllSfToQb ;
        public Boolean isPollBatchEnabled ;
        public  String currencyDetails;
        public  String multiCurrencyDetails;
        public  String selectedDurationTypeForSchedulers ;
        public String selectedDurationForSchedulers;
        public string AutoRunInterval ;
        
        //for custom fields mapping page
        @AuraEnabled
        public CustomFieldWrapper[] CustomField;
        @AuraEnabled
        public List<SelectOptionClass> SelectOptionList;
    }
    global class CustomFieldsListJson{
        @AuraEnabled
        public CustomFieldWrapper[] CustomField;
    }
    
    global class CustomFieldWrapper{
        @AuraEnabled
        public String DefinitionId{get;set;} 
        @AuraEnabled
        public String Type{get;set;} 
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public string StringValue{get;set;}
        public CustomFieldWrapper(){
        }
    }
    
    global class SelectOptionClass implements Comparable{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        public SelectOptionClass(String label,String value){     
            this.label=label;
            this.value=value;
        }
        //For sorting wrapper class
        global Integer compareTo(Object ObjToCompare) {
            return label.CompareTo(((SelectOptionClass)ObjToCompare).label);
        }
    }
}
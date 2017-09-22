/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_QuickbooksAPI{
    /*
   static TestMethod void method1(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
            upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=Date.today();
    QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=Date.today();
    QuickBookAuth.AutoRunDuration__c='15';
    
    ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
    String sch = '0 0 22 * * ?'; 
    QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1); 
    upsert  QuickBookAuth Name__c;
  
   Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        
        PageReference pageRef = Page.QuickbooksIntegrationAuth;
        Test.setCurrentPage(pageRef);
        
        QuickbooksAPI obj= new QuickbooksAPI();
        
        obj.Back();
        obj.createTaxAgency();
        obj.SyncAllQbToSf='(In Progress)';
        obj.SyncAllSfToQb='(In Progress)';
        obj.pollBatchRunStatus();
        
        obj.getAutoRunIntervalList();
        string str=obj.selectedDurationTypeForSchedulers;
        string str2=obj.selectedDurationForSchedulers;
        string str3=obj.AutoRunInterval;
        obj.fetchSchedulerTime(30);
        obj.IsQBConnected=true;
        
        obj.syncAllDataSFToQB();
        obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
        obj.OAuth_Step2_getFinalToken() ;
        obj.refreshCurrencyDetails();
        obj.mapQBFieldPage();
        
        obj.syncAllDataQBToSF();
        System.assertEquals(QuickBookAuth.Tax_Agency__c,Null);
    Test.stopTest();
    }
    
   static TestMethod void method2(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
                upsert   map1 Mapping_Object_Name__c;
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=Date.today();
        QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=Date.today();
        QuickBookAuth.AutoRunDuration__c='15';
       
       ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
            
        String sch = '0 0 22 * * ?'; 
        QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1); 
       upsert  QuickBookAuth Name__c;
       
       Test.startTest();
            QuickbooksAPI obj= new QuickbooksAPI();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            QuickbooksUtility.getServiceSettings();
            obj.Back();
            obj.SyncAllQbToSf='(In Progress)';
            obj.SyncAllSfToQb='(In Progress)';
            obj.pollBatchRunStatus();
            obj.getAutoRunIntervalList();
            string str=obj.selectedDurationTypeForSchedulers;
            string str1=obj.selectedDurationForSchedulers;
            string str2=obj.AutoRunInterval;
            obj.refreshCurrencyDetails();
            obj.fetchSchedulerTime(30);
            QuickbooksAPI.getUrlParams('test1&test2');
            obj.syncAllDataSFToQB();
            
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            
            obj.mapQBFieldPage();
            obj.syncAllDataQBToSF();
            System.assertNotEquals(QuickbooksUtility.getServiceSettings(),Null);
        Test.stopTest();
   }
  
   static TestMethod void method3(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
            upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
    QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=DateTime.newInstance(2000, 5, 5, 5, 5, 5);
    QuickBookAuth.AutoRunDuration__c='15';
    
    ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
    String sch = '0 0 22 * * ?'; 
    QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1);
            upsert  QuickBookAuth Name__c;

   Test.startTest();
        QuickbooksAPI obj= new QuickbooksAPI();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        try{
        obj.Back();
        obj.SyncAllQbToSf='(In Progress)';
        obj.SyncAllSfToQb='(In Progress)';
        obj.pollBatchRunStatus();
        obj.fetchSchedulerTime(30);
        obj.OAuth_Step2_getFinalToken() ;
        obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
        obj.syncAllDataSFToQB();
        obj.syncAllDataQBToSF();
        obj.refreshCurrencyDetails();
        obj.startSchedulers();
        }catch(exception e){
            obj.startSchedulers();
            
        }
        System.assertNotEquals(QuickbooksUtility.getServiceSettings(),Null);
    Test.stopTest();
   }
   static TestMethod void method4(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
            upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=Date.today();
    QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=Date.today();
    QuickBookAuth.AutoRunDuration__c='15';
    
    ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
    String sch = '0 0 22 * * ?'; 
    QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1);
            upsert  QuickBookAuth Name__c;
    
    
   Test.startTest();
        QuickbooksAPI obj= new QuickbooksAPI();
        try{
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
        obj.SyncAllQbToSf='';
        obj.SyncAllSfToQb='';
        obj.pollBatchRunStatus();
        
        obj.OAuth_Step2_getFinalToken() ;
        obj.disconnectQB();
        System.assertEquals(QuickBookAuth.Tax_Agency__c,Null);
        obj.syncAllDataSFToQB();
        obj.syncAllDataQBToSF();
        obj.refreshCurrencyDetails();
        }catch(exception e){
            obj.startSchedulers();
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            
        }
        System.assertNotEquals(QuickbooksUtility.getServiceSettings(),Null);
    Test.stopTest();
   }
   
   static TestMethod void method5(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
            upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=Date.today();
    QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=Date.today();
    QuickBookAuth.AutoRunDuration__c='15';
    
    ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
    String sch = '0 0 22 * * ?'; 
    QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1);
            upsert  QuickBookAuth Name__c;
            
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        QuickbooksAPI obj= new QuickbooksAPI();
        try{
        Boolean check=obj.IsQBConnected;
        obj.refreshCurrencyDetails();
        obj.disconnectQB();
        System.assertEquals(QuickBookAuth.Tax_Agency__c,Null);
        obj.syncAllDataSFToQB();
        obj.syncAllDataQBToSF();
        obj.startSchedulers();
        
        
        }catch(exception e){
            obj.startSchedulers();
        obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
        }
        System.assertNotEquals(QuickbooksUtility.getServiceSettings(),Null);
    Test.stopTest();
   }
   static TestMethod void method6(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","selectedField":"Custom_Field1__c","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","selectedField":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","selectedField":"","Name":"TestField3","DefinitionId":"3"}]}');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        QuickBookAuth.Last_Sync_All_Qb_To_Sf__c=Date.today();
        QuickBookAuth.Last_Sync_All_Sf_To_Qb__c=Date.today();
        QuickBookAuth.AutoRunDuration__c='15';
        ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
    String sch = '0 0 22 * * ?'; 
    QuickBookAuth.ReconnectCronJobId__c=system.schedule('Test Scheduler Check'+system.Now(), sch, sh1);
                upsert  QuickBookAuth Name__c;
        Test.startTest();
            QuickbooksAPI obj= new QuickbooksAPI();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            try{
            Boolean check=obj.IsQBConnected;
            obj.pollBatchRunStatus();
            obj.syncAllDataSFToQB();
            obj.syncAllDataQBToSF();
            obj.disconnectQB();
            obj.startSchedulers();
            obj.mapQBFieldPage();
            obj.refreshCurrencyDetails();
            
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            System.assertEquals(QuickBookAuth.Tax_Agency__c,Null);
            }catch(exception e){
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            }
            System.assertNotEquals(QuickbooksUtility.getServiceSettings(),Null);
        Test.stopTest();
   }
   static TestMethod void method7(){
    
        Test.startTest();
            QuickbooksAPI obj= new QuickbooksAPI();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            try{
            obj.OAuth_Step2_getFinalToken() ;
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            Boolean check=obj.IsQBConnected;
            obj.pollBatchRunStatus();
            obj.syncAllDataSFToQB();
            obj.syncAllDataQBToSF();
            obj.disconnectQB();
            obj.startSchedulers();
            obj.mapQBFieldPage();
            obj.refreshCurrencyDetails();
            obj.Back();
            
            QuickbooksAPI obj1= new QuickbooksAPI();
            obj1.SyncAllQbToSf='(In Progress)';
            obj1.SyncAllSfToQb='(In Progress)';
            obj1.pollBatchRunStatus();
            obj1.fetchSchedulerTime(30);
            obj1.OAuth_Step2_getFinalToken() ;
            obj1.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            obj1.syncAllDataSFToQB();
            obj1.syncAllDataQBToSF();
            obj1.refreshCurrencyDetails();
            obj1.startSchedulers();
            
            System.assertNotEquals(obj1.SyncAllSfToQb,Null);
            }catch(exception e){
            obj.OAuth_Step1_getTempTokenAndRedirectToIntuit();
            }
            
        Test.stopTest();
   }*/

}
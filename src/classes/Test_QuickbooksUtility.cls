/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_QuickbooksUtility{
/*
   static TestMethod void method1(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
            upsert   map1 Mapping_Object_Name__c;
   
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
            upsert  QuickBookAuth Name__c;
      
       Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            QuickbooksUtility.getMappingObject();
        
            QuickbooksUtility.readAccount('111','1');
            QuickbooksUtility.QueryFromQB('111','test customer','customer');
            QuickbooksUtility.readInvoice('111','1','invoice');
            QuickbooksUtility.getTaxCode(10.00,'111','');
            QuickbooksUtility.createNewtTaxCode(10.00,'111','');
            QuickbooksUtility.createTaxAgency('111');
            QuickbooksUtility.createNewTaxAgency('111');
            try{
                QuickbooksUtility.readPreferenceObject('111');
            }catch(exception e){}
            System.assertEquals(QuickbooksUtility.getMappingObject(),map1);
        Test.stopTest();
    }
   
    static TestMethod void method3(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
            upsert   map1 Mapping_Object_Name__c;
   
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
            upsert  QuickBookAuth Name__c;
      
       Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            QuickbooksUtility.getMappingObject();
        
            QuickbooksUtility.readAccount('333','333');
            QuickbooksUtility.QueryFromQB('333','test customer','item');
            QuickbooksUtility.readInvoice('333','333','estimate');
            QuickbooksUtility.createNewtTaxCode(10.00,'333','');
            QuickbooksUtility.createNewTaxAgency('333');
            try{
                QuickbooksUtility.readPreferenceObject('333');
            }catch(exception e){}
            
            System.assertEquals(QuickbooksUtility.getMappingObject(),map1);
        Test.stopTest();
    }
    static TestMethod void method4(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
            upsert   map1 Mapping_Object_Name__c;
   
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,Temporary_Token_Secret__c='test123',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
            upsert  QuickBookAuth Name__c;
      
       Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            QuickbooksUtility.getMappingObject();
        
            QuickbooksUtility.readAccount('401','401');
            QuickbooksUtility.QueryFromQB('401','test customer','item');
            QuickbooksUtility.readInvoice('401','401','invoice');
            QuickbooksUtility.createNewtTaxCode(10.00,'401','');
            QuickbooksUtility.createNewTaxAgency('401');
            try{
                QuickbooksUtility.readPreferenceObject('401');
            }catch(exception e){}
            System.assertEquals(QuickbooksUtility.getMappingObject(),map1);
        Test.stopTest();
    }
    */
}
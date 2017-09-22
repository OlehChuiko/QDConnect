/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_ReconnectApiScheduledClass{
   static TestMethod void method1(){
      QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
      
       
            upsert  QuickBookAuth Name__c;
      Test.startTest();
          
           ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
           Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
           String sch = '0 0 22 * * ?'; 
           system.schedule('Test Scheduler Check111'+system.Now(), sch, sh1); 
           
           ReconnectApiScheduledClass sh11 = new ReconnectApiScheduledClass();
           String sch2 = '0 0 23 * * ?'; 
           system.schedule('ReconnectApiScheduledClass121 running at '+system.Now(), sch2, sh11);
           
            System.assertEquals(QuickBookAuth.ReconnectCronJobId__c,Null);
        Test.stopTest();
    }
    static TestMethod void method2(){
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
        
            upsert  QuickBookAuth Name__c;
       Test.startTest();
          
           ReconnectApiScheduledClass sh1 = new ReconnectApiScheduledClass();
           Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
           String sch = '0 0 22 * * ?'; 
           QuickBookAuth.ReconnectCronJobId__c=system.schedule('ReconnectApiScheduledClass222 running at '+system.Now(), sch, sh1); 
           
           ReconnectApiScheduledClass sh11 = new ReconnectApiScheduledClass();
           String sch2 = '0 0 23 * * ?'; 
           system.schedule('ReconnectApiScheduledClass333 running at '+system.Now(), sch2, sh11);
        
          System.assertNotEquals(QuickBookAuth.ReconnectCronJobId__c,Null);  
        Test.stopTest();
    }
    
}
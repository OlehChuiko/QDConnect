/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapOppToQuickBookController {
   static TestMethod void method1(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
       
    Account a= new Account(Name='testAcc');
    a.billingStreet='Test';
    a.billingState='Test';
    a.BillingCity='Test';
    a.BillingCountry='Test';
    a.BillingPostalCode='Test';
    a.ShippingStreet='Test';
    a.ShippingState='Test';
    a.ShippingCity='Test';
    a.ShippingCountry='Test';
    a.ShippingPostalCode='Test';
    a.FAX='90010101010';
    a.phone='90010101010';
    insert a;
   
    opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
    insert acc;
    
    
    
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
        
        obj.redirectToOpp();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createOpp();
        
        
        //For Batch Class
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler MapOpportunityToQuickBookBatch at'+system.now(), sch2, new MapOpportunityToQuickBookBatch());
        
        System.AssertEquals(acc.QB_Id__c,Null);
    Test.stopTest();
    }
   static TestMethod void method2(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=false,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
    
    Account a= new Account(Name='testAcc',QB_Id__c='222-11');
    insert a;
    
    Account a1= new Account(Name='testAcc');
    insert a1;
   
    opportunity acc1 = new opportunity(Name='Test1',QB_Id__c='222-39',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,description='test');
    insert acc1;
    
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createOpp();
        obj.redirectToOpp();
        
        //For Batch Class
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler MapOpportunityToQuickBookBatch'+system.now(), sch2, new MapOpportunityToQuickBookBatch());
        system.schedule('Test Scheduler QuickBookInvoiceScheduler'+system.now(), sch2, new QuickBookInvoiceScheduler());
        System.AssertEquals(acc1.QB_Id__c,'222-39');
    Test.stopTest();
   }
   static TestMethod void method3(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
       
    Account a= new Account(Name='testAcc',QB_Id__c='222-11');
    insert a;
   
    opportunity acc1 = new opportunity(Name='Test1',QB_Id__c='222-39',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,description='test');
    insert acc1;
    
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createOpp();
        obj.redirectToOpp();
        
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler MapOpportunityToQuickBookBatch'+system.now(), sch2, new MapOpportunityToQuickBookBatch());
        system.schedule('Test Scheduler QuickBookInvoiceScheduler'+system.now(), sch2, new QuickBookInvoiceScheduler());
        System.AssertEquals(acc1.QB_Id__c,'222-39');
    Test.stopTest();
   }
   static TestMethod void method4(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
       
    Account a= new Account(Name='testAcc');
    insert a;
   
    opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,description='test');
    insert acc;
    
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createOpp();
        
        //For Batch Class
        set<id> sid= new set<id>();
        sid.add(acc.id);
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler Check1'+system.now(), sch2, new MapOpportunityToQuickBookBatch(sid));
        system.schedule('Test Scheduler MapOpportunityToQuickBookBatch'+system.now(), sch2, new MapOpportunityToQuickBookBatch());
        system.schedule('Test Scheduler QuickBookInvoiceScheduler'+system.now(), sch2, new QuickBookInvoiceScheduler());
        System.AssertEquals(acc.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void method5(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
       
    Account a= new Account(Name='testAcc',QB_Id__c='401-1');
    insert a;
   
    opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,description='test');
    insert acc;
    
   
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createOpp();
        
        //For Batch Class
        set<id> sid= new set<id>();
        sid.add(acc.id);
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler Check1'+system.now(), sch2, new MapOpportunityToQuickBookBatch(sid));
        system.schedule('Test Scheduler MapOpportunityToQuickBookBatch'+system.now(), sch2, new MapOpportunityToQuickBookBatch());
        system.schedule('Test Scheduler QuickBookInvoiceScheduler'+system.now(), sch2, new QuickBookInvoiceScheduler());
        System.AssertEquals(acc.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void method6(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    upsert  QuickBookAuth Name__c;
       
    Account a= new Account(Name='testAcc',QB_Id__c='222-1');
    insert a;
   
    opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,description='test');
    insert acc;
    
   
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
        MapOpportunityToQuickBookController obj= new MapOpportunityToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createOpp();
        System.AssertEquals(acc.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void TestTrigger(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,AutoRunDuration__c='15',OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),QuickBook_Auto_Sync__c=true,StageName='Closed won',description='test');
    insert opp;
    
   
   Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        opp.description='test123';
        update opp;
        System.AssertEquals(opp.QB_Id__c,Null);
    Test.stopTest();
   }
   
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapAccountToQuickBookController {
   static TestMethod void method1(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c; 
       
    Account acc = new Account(Name='Test1',Website='www.gmail.com');
    acc.billingStreet='Test';
    acc.billingState='Test';
    acc.BillingCity='Test';
    acc.BillingCountry='Test';
    acc.BillingPostalCode='Test';
    acc.ShippingStreet='Test';
    acc.ShippingState='Test';
    acc.ShippingCity='Test';
    acc.ShippingCountry='Test';
    acc.ShippingPostalCode='Test';
    acc.FAX='90010101010';
    insert acc;
    
    Account acc1 = new Account(Name='Test',QB_Id__c='111-1',Website='www.gmail.com',description='test');
    insert acc1;
    
    acc1.Phone='123456789';
    update acc1;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=acc.id);
    insert opp;
    
    Test.startTest();
    
    ApexPages.currentPage().getParameters().put('Id',acc.id); 
    ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
    MapAccountToQuickBookController obj= new MapAccountToQuickBookController(stdController);
    
    obj.redirectToAccount();
    
    Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
    obj.createAccount();
    
    //Case 2
    ApexPages.currentPage().getParameters().put('Id',acc1.id);
    ApexPages.StandardController stdController1= new ApexPages.StandardController(acc1);
    MapAccountToQuickBookController obj1= new MapAccountToQuickBookController(stdController1);

    Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
    obj1.createAccount();
    
    //For Batch Class
    Database.executeBatch(new MapAccountToQuickBookBatch() ,1);
    
    System.AssertNotEquals(acc1.QB_Id__c,Null);
    Test.stopTest();
    }
   static TestMethod void method2(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');   
    
    
    upsert  QuickBookAuth Name__c;   
    
    Account acc = new Account(Name='Test1',Website='www.gmail.com',description='test');
    insert acc;
    
    Account acc1 = new Account(Name='Test1',QB_Id__c='111-1',Website='www.gmail.com',description='test');
    acc1.billingStreet='Test';
    acc1.billingState='Test';
    acc1.BillingCity='Test';
    acc1.BillingCountry='Test';
    acc1.BillingPostalCode='Test';
    acc1.ShippingStreet='Test';
    acc1.ShippingState='Test';
    acc1.ShippingCity='Test';
    acc1.ShippingCountry='Test';
    acc1.ShippingPostalCode='Test';
    insert acc1;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=acc.id);
    insert opp;
    
    
    Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapAccountToQuickBookController obj= new MapAccountToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createAccount();
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.StandardController stdController1= new ApexPages.StandardController(acc);
        MapAccountToQuickBookController obj1= new MapAccountToQuickBookController(stdController1);
        
        obj1.redirectToAccount();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createAccount();
        //For Batch Class
        Database.executeBatch(new MapAccountToQuickBookBatch() ,1);
        
        System.AssertNotEquals(acc1.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void method3(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
    
    Account acc = new Account(Name='Test1',Website='www.gmail.com',description='test');
    insert acc;
    
    Account acc1 = new Account(Name='Test1',QB_Id__c='333-333',Website='www.gmail.com',description='test');
    insert acc1;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=acc.id);
    insert opp;
    
    
    Test.startTest();
   
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapAccountToQuickBookController obj= new MapAccountToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createAccount();
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.StandardController stdController1= new ApexPages.StandardController(acc);
        MapAccountToQuickBookController obj1= new MapAccountToQuickBookController(stdController1);
        
        obj1.redirectToAccount();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createAccount();
        //For Batch Class
        Database.executeBatch(new MapAccountToQuickBookBatch() ,1);
        
        System.AssertNotEquals(acc1.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void method4(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;  
    
    Account acc = new Account(Name='Test1',Website='www.gmail.com',description='test');
    insert acc;
    
    Account acc1 = new Account(Name='Test1',QB_Id__c='401-401',Website='www.gmail.com',description='test');
    insert acc1;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=acc.id);
    insert opp;
    
    
    Test.startTest();
   
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapAccountToQuickBookController obj= new MapAccountToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createAccount();
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',acc.id);
        ApexPages.StandardController stdController1= new ApexPages.StandardController(acc);
        MapAccountToQuickBookController obj1= new MapAccountToQuickBookController(stdController1);
        
        obj1.redirectToAccount();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createAccount();
        //For Batch Class
        Database.executeBatch(new MapAccountToQuickBookBatch() ,1);
        
        System.AssertNotEquals(acc1.QB_Id__c,Null);
    Test.stopTest();
   }
   static TestMethod void method5(){
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
    
    Account acc = new Account(Name='Test1',Website='www.gmail.com',description='test');
    insert acc;
    
    Account acc1 = new Account(Name='Test1',QB_Id__c='333-333',Website='www.gmail.com',description='test');
    insert acc1;
    
    opportunity opp = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=acc.id);
    insert opp;
    
    Test.startTest();
   
        ApexPages.currentPage().getParameters().put('Id',acc1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
        MapAccountToQuickBookController obj= new MapAccountToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createAccount();
        
        //For Batch Class
        Database.executeBatch(new MapAccountToQuickBookBatch() ,1);
        
        System.AssertNotEquals(acc1.QB_Id__c,Null);
    Test.stopTest();
   }
   
   
}
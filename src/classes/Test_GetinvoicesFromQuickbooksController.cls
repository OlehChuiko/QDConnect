/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_GetinvoicesFromQuickbooksController{
   static TestMethod void method1(){
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        
        upsert  QuickBookAuth Name__c;
        
        
        Account a= new Account(Name='testAcc',QB_Id__c='222-11');
        insert a;
       
        opportunity acc1 = new opportunity(Name='Test',QB_Id__c='222-39',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc1;
        
        Test.startTest();
            
            ApexPages.currentPage().getParameters().put('Id',acc1.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
            GetinvoicesFromQuickbooksController obj= new GetinvoicesFromQuickbooksController(stdController);
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            
            obj.readAllInvoices();
            obj.Back();
            
            
            
            PageReference pageRef = Page.GetInvoicesFromQuickbooks;
            Test.setCurrentPage(pageRef);
            
            DataBase.executeBatch(new QuickBookInvoiceScheduler(new QuickBookInvoiceScheduler().getSchedulerTime()),5);
            list<Invoice__c> InvoiceList=[select id from Invoice__c where opportunity__c=:acc1.id];
            System.AssertEquals(InvoiceList.size(),1);
        Test.stopTest();
        
    }
   
   static TestMethod void method2(){
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
       
        upsert  QuickBookAuth Name__c;
        
   
        Account a= new Account(Name='testAcc',QB_Id__c='222-11');
        insert a;
       
        opportunity acc1 = new opportunity(Name='Test',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc1;
        
        opportunity acc = new opportunity(Name='Test',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,QB_Id__c='222-39');
        insert acc;
        
       Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',acc1.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
            GetinvoicesFromQuickbooksController obj= new GetinvoicesFromQuickbooksController(stdController);
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            obj.readAllInvoices();
            //Case 2
            ApexPages.currentPage().getParameters().put('Id',acc.id); 
            
            ApexPages.StandardController stdController1= new ApexPages.StandardController(acc);
            GetinvoicesFromQuickbooksController obj1= new GetinvoicesFromQuickbooksController(stdController1);
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj1.readAllInvoices();
            
            list<Invoice__c> payList=[select id from Invoice__c where opportunity__c=:acc.id];
            //For Batch Class
            DataBase.executeBatch(new QuickBookInvoiceScheduler(new QuickBookInvoiceScheduler().getSchedulerTime()),5);
            System.AssertNotEquals(payList.size(),0);
        Test.stopTest();
        
    }
    static TestMethod void method3(){
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=false,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
        
   
        Account a= new Account(Name='testAcc',QB_Id__c='222-11');
        insert a;
        
        opportunity acc = new opportunity(Name='Test',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,QB_Id__c='222-39');
        insert acc;
        
       Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',acc.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
            GetinvoicesFromQuickbooksController obj= new GetinvoicesFromQuickbooksController(stdController);
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            
            obj.readAllInvoices();
            
            DataBase.executeBatch(new QuickBookInvoiceScheduler(new QuickBookInvoiceScheduler().getSchedulerTime()),5);
            list<Invoice__c> payList=[select id from Invoice__c where opportunity__c=:acc.id];
            System.AssertEquals(payList.size(),0);
        Test.stopTest();
    }
    static TestMethod void method4(){
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=true,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        upsert  QuickBookAuth Name__c;
        
   
        Account a= new Account(Name='testAcc',QB_Id__c='222-11');
        insert a;
        
        opportunity acc = new opportunity(Name='Test',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,QB_Id__c='222-39');
        insert acc;
        
       Test.startTest();
            ApexPages.currentPage().getParameters().put('Id',acc.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(acc);
            GetinvoicesFromQuickbooksController obj= new GetinvoicesFromQuickbooksController(stdController);
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.readAllInvoices();
            
            list<Invoice__c> payList=[select id from Invoice__c where opportunity__c=:acc.id];
            
            //For Batch Class
            String sch2 = '0 0 23 * * ?'; 
            system.schedule('Test Scheduler QuickBookInvoiceScheduler'+system.now(), sch2, new QuickBookInvoiceScheduler());
            System.AssertEquals(payList.size(),1);
        Test.stopTest();
    }
    static TestMethod void method5(){
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='222',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        
        upsert  QuickBookAuth Name__c;
        
        
        Account a= new Account(Name='testAcc',QB_Id__c='222-11');
        insert a;
       
        opportunity acc1 = new opportunity(Name='Test',QB_Id__c='222-39',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc1;
        
        Test.startTest();
            
            ApexPages.currentPage().getParameters().put('Id',acc1.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(acc1);
            GetinvoicesFromQuickbooksController obj= new GetinvoicesFromQuickbooksController(stdController);
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            DataBase.executeBatch(new QuickBookInvoiceScheduler(new QuickBookInvoiceScheduler().getSchedulerTime()),1);
            PageReference pageRef = Page.GetInvoicesFromQuickbooks;//Observe how we set the Page here
            Test.setCurrentPage(pageRef);//Applying page context here
            
            list<Invoice__c> InvoiceList=[select id from Invoice__c where opportunity__c=:acc1.id];
            System.AssertEquals(InvoiceList.size(),0);
        Test.stopTest();
    }
    
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapSalesTermsToQuickBookController{
   static TestMethod void method1(){
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
       upsert  QuickBookAuth Name__c;
        
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       insert term;
       
       terms__C term1= new terms__C();
       term1.name='test New';
       term1.Is_Active__c=True;
       term1.Type__c='STANDARD';
       term1.Due_Days__c=10;
       term1.Discount_Percent__c=15.00;
       term1.QB_Id__c='111-111';
       insert term1;
       
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.redirectToterm();
        obj.createterm();
        
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',term1.id); 
        
        ApexPages.StandardController stdController1= new ApexPages.StandardController(term1);
        MapSalesTermsToQuickBookController obj1= new MapSalesTermsToQuickBookController(stdController1);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createterm();
        obj1.redirectToterm();
        
        System.AssertEquals(term.QB_Id__c,Null);
        System.AssertEquals(term.QB_Error__c,Null);
        Test.stopTest();
    }
    static TestMethod void method1of1(){
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
       upsert  QuickBookAuth Name__c;
        
       terms__C term= new terms__C();
       term.name='test new';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       insert term;
       
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.redirectToterm();
        obj.createterm();
        
        System.AssertEquals(term.QB_Id__c,null);
        System.AssertEquals(term.QB_Error__c,Null);
        Test.stopTest();
    }
    static TestMethod void method2(){
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='400',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
       
        upsert  QuickBookAuth Name__c;
        
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       term.QB_Id__c='400-400';
       insert term;
       
       terms__C term1= new terms__C();
       term1.name='test New';
       term1.Is_Active__c=True;
       term1.Type__c='STANDARD';
       term1.Due_Days__c=10;
       term1.Discount_Percent__c=15.00;
       insert term1;
       
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createterm();
        obj.redirectToterm();
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',term1.id); 
        
        ApexPages.StandardController stdController1= new ApexPages.StandardController(term1);
        MapSalesTermsToQuickBookController obj1= new MapSalesTermsToQuickBookController(stdController1);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createterm();
        obj1.redirectToterm();
        
        System.AssertNotEquals(term.QB_Id__c,Null);
        System.AssertEquals(term.QB_Error__c,Null);
        Test.stopTest();
    }
    static TestMethod void method3(){
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
       
        upsert  QuickBookAuth Name__c;
        
       
       
       
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       term.QB_Id__c='401-401';
       insert term;
       
       terms__C term1= new terms__C();
       term1.name='test New';
       term1.Is_Active__c=True;
       term1.Type__c='STANDARD';
       term1.Due_Days__c=10;
       term1.Discount_Percent__c=15.00;
       insert term1;
       
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createterm();
        obj.redirectToterm();
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',term1.id); 
        
        ApexPages.StandardController stdController1= new ApexPages.StandardController(term1);
        MapSalesTermsToQuickBookController obj1= new MapSalesTermsToQuickBookController(stdController1);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createterm();
        obj1.redirectToterm();
        
        System.AssertNotEquals(term.QB_Id__c,Null);
        System.AssertEquals(term.QB_Error__c,Null);
        Test.stopTest();
    }
    static TestMethod void method4(){
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
        upsert  QuickBookAuth Name__c;
       
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       term.QB_Id__c='111-111';
       insert term;
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createterm();
        obj.redirectToterm();
        
        System.AssertEquals(term.QB_Error__c,Null);
        
        Test.stopTest();
    }
    static TestMethod void method5(){
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=false,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
       upsert  QuickBookAuth Name__c;
        
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       term.QB_Id__c='111-111';
       insert term;
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createterm();
        obj.redirectToterm();
        
        System.AssertEquals(term.QB_Error__c,Null);
        
        Test.stopTest();
    }
    static TestMethod void method6(){
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
        upsert  QuickBookAuth Name__c;
       
       terms__C term= new terms__C();
       term.name='test';
       term.Is_Active__c=True;
       term.Type__c='STANDARD';
       term.Due_Days__c=10;
       term.Discount_Percent__c=15.00;
       term.QB_Id__c='111-111';
       insert term;
       Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',term.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(term);
        MapSalesTermsToQuickBookController obj= new MapSalesTermsToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createterm();
        obj.redirectToterm();
        
        System.AssertEquals(term.QB_Error__c,Null);
        
        Test.stopTest();
    }
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapInvoiceToQuickBookController {
   static TestMethod void method1(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuoteInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
        
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
        
       
       Test.startTest();
        Product2 p = new product2(name='unittest');
        p.Family = 'License';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
       
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
        insert a;
        
        terms__C term= new terms__C();
        term.name='Test 30';
        term.Is_Active__c=True;
        term.Type__c='STANDARD';
        term.Due_Days__c=10;
        term.Discount_Percent__c=15.00;
        insert term;
        
        opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc;
        
        quote q=new quote(QB_Shipping_Method__c='test123',name='myquote',opportunityid=acc.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
        q.Sales_Term__c=term.id;
        q.billingName='Test';
        q.billingStreet='Test';
        q.billingState='Test';
        q.BillingCity='Test';
        q.BillingCountry='Test';
        q.BillingPostalCode='Test';
        q.ShippingStreet='Test';
        q.ShippingState='Test';
        q.ShippingCity='Test';
        q.ShippingCountry='Test';
        q.ShippingPostalCode='Test';
        q.FAX='90010101010';
         insert q;
        
        quoteLineItem i = new quotelineitem(); 
        i.quoteid      = q.id; 
        i.pricebookentryid    = pbe.id; 
        i.quantity            = 1; 
        i.unitprice           = 1; 
           
        Database.insert(i); 
        
        quoteLineItem i1 = new quotelineitem(); 
        i1.quoteid      = q.id; 
        i1.pricebookentryid    = pbe.id; 
        i1.quantity            = 1; 
        i1.unitprice           = 1; 
           
        Database.insert(i1); 
       
        ApexPages.currentPage().getParameters().put('Id',q.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(q);
        MapInvoiceToQuickBookController obj= new MapInvoiceToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.redirectToQuote();
        obj.createInvoice();
        
        System.AssertEquals(acc.QB_Id__c,Null);
        System.AssertEquals(q.QB_Id__c,Null);
        
        q.QB_Object_Type__c='Invoice';
        update q;
        //For Batch Class
        MapInvoiceToQuickBookBatch sh11 = new MapInvoiceToQuickBookBatch();
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler Check1 running at '+system.now(), sch2, sh11);
        
        Test.stopTest();
    }
   static TestMethod void method2(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuoteInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
        
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
        
       
       Test.startTest();     
        Product2 p = new product2(name='unittest');
        p.Family = 'License';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
       
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
        insert a;
        
        terms__C term= new terms__C();
        term.name='Test 30';
        term.Is_Active__c=True;
        term.Type__c='STANDARD';
        term.Due_Days__c=10;
        term.Discount_Percent__c=15.00;
        insert term;
        
        opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc;
        
        quote q=new quote(QB_Shipping_Method__c='test123',name='myquote',opportunityid=acc.id,pricebook2id=pricebookId,description='test',Tax=60,QB_Id__c='111-1');
        q.Sales_Term__c=term.id;
        q.billingName='Test';
        q.billingStreet='Test';
        q.billingState='Test';
        q.BillingCity='Test';
        q.BillingCountry='Test';
        q.BillingPostalCode='Test';
        q.ShippingStreet='Test';
        q.ShippingState='Test';
        q.ShippingCity='Test';
        q.ShippingCountry='Test';
        q.ShippingPostalCode='Test';
        q.FAX='90010101010';
        insert q;
         
        quoteLineItem i = new quotelineitem(); 
        i.quoteid      = q.id; 
        i.pricebookentryid    = pbe.id; 
        i.quantity            = 1; 
        i.unitprice           = 1; 
           
        Database.insert(i); 
        
        ApexPages.currentPage().getParameters().put('Id',q.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(q);
        MapInvoiceToQuickBookController obj= new MapInvoiceToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createInvoice();
        obj.redirectToQuote();
        
        System.AssertEquals(acc.QB_Id__c,Null);
        System.AssertNotEquals(q.QB_Id__c,Null);
        
        q.QB_Object_Type__c='Invoice';
        update q;
        //For Batch Class
        MapInvoiceToQuickBookBatch sh11 = new MapInvoiceToQuickBookBatch();
        String sch2 = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler Check1 running at '+system.now(), sch2, sh11);
        Test.stopTest();
       }
    static TestMethod void method4(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuoteInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
        
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
        
       
        Test.startTest();    
        Product2 p = new product2(name='unittest',QB_Id__c='333-1');
        p.Family = 'License';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
       
        Account a= new Account(Name='testAcc',QB_Id__c='333-333');
        insert a;
        
        opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,QB_Id__c='333-333');
        insert acc;
        
        quote q=new quote(QB_Shipping_Method__c='test123',name='myquote',opportunityid=acc.id,pricebook2id=pricebookId,description='test',QB_Tax_Percent__c=6);
        q.billingStreet='Test';
        q.billingState='Test';
        q.BillingCity='Test';
        q.BillingCountry='Test';
        q.BillingPostalCode='Test';
        q.ShippingStreet='Test';
        q.ShippingState='Test';
        q.ShippingCity='Test';
        q.ShippingCountry='Test';
        q.ShippingPostalCode='Test';
        q.FAX='90010101010';
        insert q;
        
        quoteLineItem i = new quotelineitem(); 
        i.quoteid      = q.id; 
        i.pricebookentryid    = pbe.id; 
        i.quantity            = 1; 
        i.unitprice           = 1; 
           
        Database.insert(i); 
        
        ApexPages.currentPage().getParameters().put('Id',q.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(q);
        MapInvoiceToQuickBookController obj= new MapInvoiceToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createInvoice();
        
        System.AssertNotEquals(acc.QB_Id__c,Null);
        System.AssertEquals(q.QB_Id__c,Null);
        
        q.QB_Object_Type__c='Invoice';
        update q;
        //For Batch Class
        Database.executeBatch(new MapInvoiceToQuickBookBatch() ,1);
        Test.stopTest();
       }
       static TestMethod void method5(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
        
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
        
       
       Test.startTest();     
        Product2 p = new product2(name='unittest',QB_Id__c='401-401');
        p.Family = 'License';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
        
        Account a= new Account(Name='testAcc',QB_Id__c='401-401');
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
        insert a;
        
        opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id,QB_Id__c='401-401');
        insert acc;
        
        quote q=new quote(name='myquote',opportunityid=acc.id,pricebook2id=pricebookId,description='test',QB_Id__c='401-401',Tax=60);
         insert q;
         
        
        quoteLineItem i = new quotelineitem(); 
        i.quoteid      = q.id; 
        i.pricebookentryid    = pbe.id; 
        i.quantity            = 1; 
        i.unitprice           = 1; 
           
        Database.insert(i); 
        
            ApexPages.currentPage().getParameters().put('Id',q.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(q);
            MapInvoiceToQuickBookController obj= new MapInvoiceToQuickBookController(stdController);
        
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            obj.createInvoice();
            obj.redirectToQuote();
            
        
            System.AssertNotEquals(acc.QB_Id__c,Null);
            System.AssertNotEquals(q.QB_Id__c,Null);
            
            q.QB_Object_Type__c='Invoice';
            update q;
            //For Batch Class
            Database.executeBatch(new MapInvoiceToQuickBookBatch() ,1);
        Test.stopTest();
       }
       static TestMethod void method3(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
       
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
       
       
       Test.startTest();
        Product2 p = new product2(name='unittest',QB_Id__c='333-333');
        p.Family = 'License';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
       
        Account a= new Account(Name='testAcc',QB_Id__c='333-333');
        insert a;
        
        opportunity acc = new opportunity(Name='Test1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
        insert acc;
        
        quote q=new quote(name='myquote',opportunityid=acc.id,pricebook2id=pricebookId,description='test',QB_Tax_Percent__c=6);
     
         insert q;
        
        quoteLineItem i = new quotelineitem(); 
        i.quoteid      = q.id; 
        i.pricebookentryid    = pbe.id; 
        i.quantity            = 1; 
        i.unitprice           = 1; 
           
        Database.insert(i); 
        
        ApexPages.currentPage().getParameters().put('Id',q.id); 
        ApexPages.StandardController stdController= new ApexPages.StandardController(q);
        MapInvoiceToQuickBookController obj= new MapInvoiceToQuickBookController(stdController);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj.createInvoice();
        
        System.AssertEquals(acc.QB_Id__c,Null);
        System.AssertEquals(q.QB_Id__c,Null);
        
        q.QB_Object_Type__c='Invoice';
        update q;
        //For Batch Class
        Database.executeBatch(new MapInvoiceToQuickBookBatch() ,1);
        Test.stopTest();
    }
    
}
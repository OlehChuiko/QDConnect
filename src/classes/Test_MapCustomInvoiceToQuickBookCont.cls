/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapCustomInvoiceToQuickBookCont{
   static TestMethod void method1(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
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
            
            opportunity acc1 = new opportunity(Name='Test',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
            insert acc1;
            
            quote q=new quote(name='myquote',opportunityid=acc1.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
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
            
            terms__C term= new terms__C();
            term.name='Test 30';
            term.Is_Active__c=True;
            term.Type__c='STANDARD';
            term.Due_Days__c=10;
            term.Discount_Percent__c=15.00;
            insert term;
            
            Invoice__c inv= new Invoice__c(opportunity__c=acc1.id,Copy_Address_from__c='Account',Shipping_Method__c='Test',Sales_Term__c=term.id);
            inv.CustomerMemo__c='test';
            inv.Private_Note__c='test';
            insert inv;
            
            OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
              insert oli;
            
            ApexPages.currentPage().getParameters().put('Id',inv.id); 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            String sch1 = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check1', sch1,new MapCustomInvoiceToQuickBookBatch());
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(inv);
            MapCustomInvoiceToQuickBookController obj= new MapCustomInvoiceToQuickBookController(stdController);
            obj.redirectToQuote();
            obj.createInvoice();
            
            
            String sch = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check running at '+system.now(), sch,new MapCustomInvoiceToQuickBookBatch());
            
            System.AssertEquals(acc1.QB_Id__c,Null);
            System.AssertEquals(inv.QB_Id__c,Null);
        Test.stopTest();
    }
    
   static TestMethod void method2(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
       
        
        Test.startTest();
            Product2 p = new product2(name='unittest',QB_Id__c='111-1');
            p.Family = 'License';
            insert p;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
            insert pbe;
           
            Account a= new Account(Name='testAcc',QB_Id__c='111-11');
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
            
            opportunity acc1 = new opportunity(Name='Test',QB_Id__c='111-1',QB_Tax_Percent__c=6,CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
            insert acc1;
            
            
            quote q=new quote(name='myquote',opportunityid=acc1.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
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
            
            Invoice__c inv= new Invoice__c(opportunity__c=acc1.id,Copy_Address_from__c='Quote',Shipping_Method__c='Test',Sales_Term__c=term.id);
            inv.CustomerMemo__c='test';
            inv.Private_Note__c='test';
            inv.Copy_Line_Item_Description_From__c='Product';
            insert inv;
            
            OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
              insert oli;
            
            ApexPages.currentPage().getParameters().put('Id',inv.id); 
            ApexPages.StandardController stdController= new ApexPages.StandardController(inv);
            MapCustomInvoiceToQuickBookController obj= new MapCustomInvoiceToQuickBookController(stdController);
        
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.createInvoice();
            
            
            String sch = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check running at '+system.now(), sch,new MapCustomInvoiceToQuickBookBatch()); 

            System.AssertNotEquals(acc1.QB_Id__c,Null);
            System.AssertEquals(inv.QB_Id__c,Null);
        Test.stopTest();
   }
   static TestMethod void method3(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=True,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
       
        
        Test.startTest();
            Product2 p = new product2(name='unittest',QB_Id__c='111-1');
            p.Family = 'License';
            insert p;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
            insert pbe;
           
            Account a= new Account(Name='testAcc',QB_Id__c='111-11');
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
            
            opportunity acc1 = new opportunity(Name='Test',QB_Id__c='111-1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
            insert acc1;
            
            quote q=new quote(name='myquote',opportunityid=acc1.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
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
            
            Invoice__c inv1= new Invoice__c(opportunity__c=acc1.id,QB_Id__c='111-1',Copy_Address_from__c='Quote',Shipping_Method__c='Test');
            inv1.CustomerMemo__c='test';
            inv1.Copy_Line_Item_Description_From__c='Product';
            inv1.Private_Note__c='test';
            insert inv1;
            
            OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
              insert oli;
             
            
            ApexPages.currentPage().getParameters().put('Id',inv1.id); 
            
            ApexPages.StandardController stdController= new ApexPages.StandardController(inv1);
            MapCustomInvoiceToQuickBookController obj= new MapCustomInvoiceToQuickBookController(stdController);
        
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.createInvoice();
            
            String sch = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check running at '+system.now(), sch,new MapCustomInvoiceToQuickBookBatch());
            
            System.AssertNotEquals(acc1.QB_Id__c,Null);
            System.AssertNotEquals(inv1.QB_Id__c,Null);
        Test.stopTest();
       }
    static TestMethod void method4(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=True,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
       
       
        Test.startTest();
       
            Product2 p = new product2(name='unittest',QB_Id__c='333-1');
            p.Family = 'License';
            insert p;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
            insert pbe;
           
            Account a= new Account(Name='testAcc',QB_Id__c='333-1');
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
            
            opportunity acc1 = new opportunity(Name='Test',QB_Id__c='333-1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
            insert acc1;
            
            quote q=new quote(name='myquote',opportunityid=acc1.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
     
            insert q;
            Invoice__c inv= new Invoice__c(opportunity__c=acc1.id,Copy_Address_from__c='Account');
            inv.CustomerMemo__c='test';
            inv.Private_Note__c='test';
            insert inv;
            
            
            OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
              insert oli;
            OpportunityLineItem oli1 = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
              insert oli1;
            
           
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            ApexPages.currentPage().getParameters().put('Id',inv.id); 
            ApexPages.StandardController stdController= new ApexPages.StandardController(inv);
            MapCustomInvoiceToQuickBookController obj= new MapCustomInvoiceToQuickBookController(stdController);
            obj.createInvoice();
            
            String sch = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check running at '+system.now(), sch,new MapCustomInvoiceToQuickBookBatch());
            
            System.AssertNotEquals(acc1.QB_Id__c,Null);
            System.AssertEquals(inv.QB_Id__c,Null);
        Test.stopTest();
   }
   static TestMethod void method5(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=True,Company_Id__c='401',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
       
       
        Test.startTest();
            Product2 p = new product2(name='unittest',QB_Id__c='401-1');
            p.Family = 'License';
            insert p;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
            insert pbe;
           
            Account a= new Account(Name='testAcc',QB_Id__c='401-1');
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
            
            opportunity acc1 = new opportunity(Name='Test',QB_Id__c='401-1',CloseDate=Date.today(),StageName='Closed won', AccountId=a.id);
            insert acc1;
            
            quote q=new quote(name='myquote',opportunityid=acc1.id,pricebook2id=pricebookId,Tax=60,description='test',QB_Tax_Percent__c=6,QB_Estimate_Status__c='Closed',QB_Object_Type__c='Estimate');
     
            insert q;
            Invoice__c inv= new Invoice__c(opportunity__c=acc1.id,Copy_Address_from__c='Quote');
            inv.CustomerMemo__c='test';
            inv.Private_Note__c='test';
            insert inv;
            
            OpportunityLineItem oli = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
            insert oli;
            
            OpportunityLineItem oli1 = new OpportunityLineItem
            (
                OpportunityId = acc1.Id,
                PricebookEntryId = pbe.id,
                Quantity = 1,
                UnitPrice = 100, 

                ServiceDate = System.today()
            );
            insert oli1;
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            ApexPages.currentPage().getParameters().put('Id',inv.id); 
            ApexPages.StandardController stdController= new ApexPages.StandardController(inv);
            MapCustomInvoiceToQuickBookController obj= new MapCustomInvoiceToQuickBookController(stdController);
            obj.createInvoice();
            obj.redirectToQuote();
            
            String sch = '0 0 22 * * ?'; 
            system.schedule('Test Scheduler Check running at '+system.now(), sch,new MapCustomInvoiceToQuickBookBatch());
            
            System.AssertNotEquals(acc1.QB_Id__c,Null);
            System.AssertEquals(inv.QB_Id__c,Null);
        Test.stopTest();
   }
   
}
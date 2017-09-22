/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapItemToQuickBookController{
   static TestMethod void method1(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
    upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
   
    Product2 p = new product2(name='unittest');
    p.Family = 'License';
    p.Description = 'License';
    p.QB_Quantity_On_Hand__c = 50;
    p.QB_COGS_Amount__c = 10000;
    insert p;
    
    Product2 p1 = new product2(name='unittest:sunny',QB_Id__c='111-1');
    p1.Family = 'License';
    insert p1;
    
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
    insert pbe;
    
    PricebookEntry pbe1 = new PricebookEntry(pricebook2id = pricebookId, product2id = p1.id,unitprice=1.0,isActive=true);
    insert pbe1;
   
   Test.startTest();
   try{
        ApexPages.currentPage().getParameters().put('Id',p.id); 
        ApexPages.StandardController stdController= new ApexPages.StandardController(p);
        MapItemToQuickBookController obj= new MapItemToQuickBookController(stdController);
        
        obj.redirectToItem();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        MapItemToQuickBookController.QueryCOGSAccount('111','Cost Of Goods Sold');
        MapItemToQuickBookController.createCOGSAccount('111','Cost Of Goods Sold');
        obj.createItem();
        
        system.AssertEquals(p.QB_Id__c,Null);
        //Case 2
        ApexPages.currentPage().getParameters().put('Id',p1.id);
        ApexPages.StandardController stdController1= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj1= new MapItemToQuickBookController(stdController1);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        obj1.createItem();
        
        //For Batch Class
         Database.executeBatch(new MapItemToQuickBookBatch() ,10);
         
         
        system.AssertNotEquals(p1.QB_Id__c,Null);
   }catch(exception e){
        ApexPages.currentPage().getParameters().put('Id',p1.id);
        ApexPages.StandardController stdController1= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj1= new MapItemToQuickBookController(stdController1);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        MapItemToQuickBookController.QueryCOGSAccount('111','Cost Of Goods Sold');
         MapItemToQuickBookController.createCOGSAccount('111','Cost Of Goods Sold');
         obj1.createItem();
        //For Batch Class
        Database.executeBatch(new MapItemToQuickBookBatch() ,10);
        system.AssertNotEquals(p1.QB_Id__c,Null);
    }
        
    Test.stopTest();
    }
   
   static TestMethod void method3(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
    upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=True,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
   upsert  QuickBookAuth Name__c;
   
    Product2 p = new product2(name='unittest');
    p.Family = 'License';
    insert p;
    
    Product2 p1 = new product2(name='unittest:test1',QB_Id__c='333-333');
    p1.Family = 'License';
    insert p1;
    
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
    insert pbe;
   
    PricebookEntry pbe1 = new PricebookEntry(pricebook2id = pricebookId, product2id = p1.id,unitprice=1.0,isActive=true);
    insert pbe1;
   
   Test.startTest();
        
        try{
        ApexPages.currentPage().getParameters().put('Id',p1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj= new MapItemToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        
        MapItemToQuickBookController.QueryCOGSAccount('111','Cost Of Goods Sold');
        MapItemToQuickBookController.createCOGSAccount('111','Cost Of Goods Sold');
        obj.createItem();
         
        //For Batch Class
        Database.executeBatch(new MapItemToQuickBookBatch() ,10);
        system.AssertEquals(p.QB_Id__c,Null);
        
        }catch(exception e){
            
            //For Batch Class
            Database.executeBatch(new MapItemToQuickBookBatch() ,10);
            system.AssertEquals(p.QB_Id__c,Null);
        }
    Test.stopTest();
   }
    static TestMethod void method4(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
    upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=true,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=True,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    upsert  QuickBookAuth Name__c;
    
    Product2 p1 = new product2(name='unittest:125',QB_Id__c='333-333');
    p1.Family = 'License';
    insert p1;
    
    Id pricebookId = Test.getStandardPricebookId();
   
    PricebookEntry pbe1 = new PricebookEntry(pricebook2id = pricebookId, product2id = p1.id,unitprice=1.0,isActive=true);
    insert pbe1;
   
   Test.startTest();
        try{
        ApexPages.currentPage().getParameters().put('Id',p1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj= new MapItemToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        obj.createItem();
        
        //For Batch Class
        Database.executeBatch(new MapItemToQuickBookBatch() ,10);
        system.AssertEquals(p1.QB_Id__c,'333-333');
        }catch(exception e){
            MapItemToQuickBookController.QueryCOGSAccount('401','Cost Of Goods Sold');
            MapItemToQuickBookController.createCOGSAccount('401','Cost Of Goods Sold');
            //For Batch Class
            Database.executeBatch(new MapItemToQuickBookBatch() ,10);
            system.AssertNotEquals(p1.QB_Id__c,Null);
        }
    Test.stopTest();
   }
   static TestMethod void method5(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
    upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=true,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
   upsert  QuickBookAuth Name__c;
    
    Product2 p1 = new product2(name='unittest',QB_Id__c='111-111');
    p1.Family = 'License';
    insert p1;
    
    Id pricebookId = Test.getStandardPricebookId();
   
    PricebookEntry pbe1 = new PricebookEntry(pricebook2id = pricebookId, product2id = p1.id,unitprice=1.0,isActive=true);
    insert pbe1;
   
   Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',p1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj= new MapItemToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
        MapItemToQuickBookController.QueryCOGSAccount('401','Sales');
        MapItemToQuickBookController.createCOGSAccount('401','Sales');
        MapItemToQuickBookController.createItem(p1.id);
        obj.createItem();
        
        //For Batch Class
        Database.executeBatch(new MapItemToQuickBookBatch() ,10);
        system.AssertEquals(p1.QB_Id__c,'111-111');
    Test.stopTest();
   }
   static TestMethod void TestTrigger(){
    QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
    upsert   map1 Mapping_Object_Name__c;
   
    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=true,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
    
    
    upsert  QuickBookAuth Name__c;
   
    Product2 p = new product2(name='unittest');
    p.Family = 'License';
    insert p;
    
    Product2 p1 = new product2(name='unittest1',QB_Id__c='111-1');
    p1.Family = 'License';
    insert p1;
    
    Test.startTest();
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
    insert pbe;
    
    PricebookEntry pbe1 = new PricebookEntry(pricebook2id = pricebookId, product2id = p1.id,unitprice=1.0,isActive=true);
    insert pbe1;
    
     p1.description='test';
     update p1; 

    QuickBookAuth.Paid_Version__c=false;
    update QuickBookAuth;
    
     ApexPages.currentPage().getParameters().put('Id',p1.id); 
        
        ApexPages.StandardController stdController= new ApexPages.StandardController(p1);
        MapItemToQuickBookController obj= new MapItemToQuickBookController(stdController);
    
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
        
    system.AssertNotEquals(p1.QB_Id__c,Null);
    Test.stopTest();
    }
    
    static TestMethod void TestScheduler(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringType":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringType":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringType":"Name","Name":"TestField3","DefinitionId":"3"}]}');
        upsert   map1 Mapping_Object_Name__c;
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        upsert  QuickBookAuth Name__c;
       
       
        Product2 p1 = new product2(name='unittest1',QB_Id__c='111-1');
        p1.Family = 'License';
        insert p1;
        
        Test.startTest();
            set<id> Sid= new set<id>();
            sid.add(p1.id);
            String sch2 = '0 0 23 * * ?'; 
            system.schedule('Test Scheduler MapItemToQuickBookBatch at'+system.now(), sch2, new MapItemToQuickBookBatch(sid));
            system.AssertNotEquals(p1.QB_Id__c,Null);
        Test.stopTest();
    }
}
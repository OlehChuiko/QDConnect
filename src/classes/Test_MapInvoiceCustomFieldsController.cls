/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_MapInvoiceCustomFieldsController {
   static TestMethod void method1(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
       
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
       
       
       Test.startTest();
            
            PageReference pageRef = Page.MapInvoiceCustomFields;
            Test.setCurrentPage(pageRef);
            
            MapInvoiceCustomFieldsController obj= new MapInvoiceCustomFieldsController();
            obj.selectedObject='Quote';
            obj.Back();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.init();
            List<SelectOption> fieldsName =obj.fieldsName;
            obj.Cancel();
            obj.editMapping() ;
            obj.QueryDummyInvoice('111');
            obj.getCustomFieldNames();
            obj.refreshFromQB();
            obj.SaveMapping();
            
            System.AssertEquals(obj.selectedObject,'Quote');
        Test.stopTest();
    }
   static TestMethod void method2(){
        QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
        
            upsert   map1 Mapping_Object_Name__c;
       
       
        QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
        
        
        
            upsert  QuickBookAuth Name__c;
       
       
        
       Test.startTest();
            MapInvoiceCustomFieldsController obj= new MapInvoiceCustomFieldsController();
            obj.selectedObject='Invoice__C';
            obj.Back();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.init();
            obj.refreshFromQB();
            List<SelectOption> fieldsName =obj.fieldsName;
            obj.Cancel();
            obj.editMapping() ;
            obj.getCustomFieldNames();
            obj.SaveMapping();
            System.AssertEquals(obj.selectedObject,'Invoice__C');
        Test.stopTest();
   }
   static TestMethod void method3(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',Mapping_Object_Name__c='Invoice');
       
            upsert   map1 Mapping_Object_Name__c;
       
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=false,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
       
        
       Test.startTest();
            MapInvoiceCustomFieldsController obj= new MapInvoiceCustomFieldsController();
            obj.selectedObject='Invoice__c';
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            
            obj.init();
            obj.createDummyCustomer('111');
            obj.editMapping() ;
            
            obj.QueryDummyInvoice('111');
            obj.getCustomFieldNames();
            
            obj.refreshFromQB();
            obj.SaveMapping();
            obj.Cancel();
            System.AssertEquals(obj.selectedObject,'Invoice__c');
        Test.stopTest();
    }
    static TestMethod void method4(){
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
       
       
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='111',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
       
       
       Test.startTest();
            
            MapInvoiceCustomFieldsController obj= new MapInvoiceCustomFieldsController();
            obj.selectedObject='Invoice__c';
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.init();
            obj.createDummyInvoice('111');
            System.AssertEquals(obj.selectedObject,'Invoice__c');
            
        Test.stopTest();
    }
    static TestMethod void method5(){
       QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(OAuth_Token__c='test',Paid_Version__c=True,OAuth_Token_Secret__c='test2',IsSetUpComplete__c=true,Company_Id__c='333',Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
       
       
       
            upsert  QuickBookAuth Name__c;
       
        
       QB_Fields_Mapping__c map1= new QB_Fields_Mapping__c (Name='Invoice',QB_Custom_Fields_MappingQuote__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',QB_Custom_Fields_MappingInvoice__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}',Mapping_Object_Name__c='Invoice',QB_Custom_Fields_Mapping__c='{"CustomField":[{"Type":"StringType","StringValue":"Name","Name":"TestField1","DefinitionId":"1"},{"Type":"StringType","StringValue":"Name","Name":"TestField2","DefinitionId":"2"},{"Type":"StringType","StringValue":"Name","Name":"TestField3","DefinitionId":"3"}]}');
       
            upsert   map1 Mapping_Object_Name__c;
       
       
       Test.startTest();
            
            MapInvoiceCustomFieldsController obj= new MapInvoiceCustomFieldsController();
            obj.selectedObject='Invoice__c';
            obj.getCustomFieldNames();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            obj.init();
            obj.refreshFromQB();
            obj.createDummyInvoice('333');
            obj.createDummyCustomer('333');
            System.AssertEquals(obj.selectedObject,'Invoice__c');
            
        Test.stopTest();
    }
}
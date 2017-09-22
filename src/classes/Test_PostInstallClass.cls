/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_PostInstallClass 
{
    static testMethod void installTest()
    {
        test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator());
            PostInstallClass postinstall = new PostInstallClass();
            
            Test.testInstall(postinstall, null);
            Test.testInstall(postinstall, new Version(1,0), true);
            List<QuickBookAuthDetails1__c> a = [Select id, name from QuickBookAuthDetails1__c where name__c ='QuickBookAuthDetails'];
            System.assertEquals(a.size(), 1);
        test.stopTest();
    }
}
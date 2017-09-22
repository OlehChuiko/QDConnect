/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Test Class

*/
@isTest
private class Test_QBDeleteErrorLogBatch{
   static TestMethod void method1(){
    QB_Log__c log =new QB_Log__c(Class_Name__c='Test');
    insert log;
    
    Test.startTest();
      
        String strJobName = 'QBDeleteErrorLogBatch Running at '+string.valueOf(System.Now());
        String strSchedule = '0 0 0 ? * 1 * ';
        System.schedule(strJobName, strSchedule, new QBDeleteErrorLogBatch());
       
        System.assertNotEquals(log.id,Null);
    Test.stopTest();
    }
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration class for deleting QB Logs
    //Weekly Run 
    String strJobName = 'QBDeleteErrorLogBatch Running at '+string.valueOf(System.Now());
    String strSchedule = '0 0 0 ? * 1 * ';
    System.schedule(strJobName, strSchedule, new QBDeleteErrorLogBatch())

*/
global with sharing class QBDeleteErrorLogBatch implements Database.Batchable<sObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC){
        String [] FieldsToQuery = new String [] {'id'};
        if(!QuickbooksUtility.CheckFieldPermission('QB_Log__c','isAccessible',FieldsToQuery,False)){
            QB_Logger.GetLogger('QBDeleteErrorLogBatch').LogError('Insufficient access on QB_Log__c: Error in  start method in QBDeleteErrorLogBatch');
            return null;
        }
        return Database.getQueryLocator('Select id from QB_Log__c');
    }
    global void execute(Database.BatchableContext BC, List<QB_Log__c> scope)
    {
        if(QuickbooksUtility.CheckFieldPermission('QB_Log__c','isDeletable',Null,True))
            delete scope;
        else
            QB_Logger.GetLogger('QBDeleteErrorLogBatch').LogError('Error Execute method in QBDeleteErrorLogBatch for record : '+scope);
            
    }
    global void finish(Database.BatchableContext BC)
    {
    }
    
    //For schedules
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new QBDeleteErrorLogBatch());
    }
    
}
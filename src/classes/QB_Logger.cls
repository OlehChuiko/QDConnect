/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class QB_Logger {
    public string Logger { get;set; }
    public static QB_Logger GetLogger(string LoggerName) {
        return new QB_Logger(LoggerName);
    }
    
    /**
     * constructor for the service class
     */    
    public QB_Logger(string LoggerName)
    {
        Logger = LoggerName;
    }
    public void LogError(string content) {
        QB_Log__c log = new QB_Log__c();
        
        log.Class_Name__c = Logger;
        log.Error_Message__c = content;
        
        String [] FieldsToQuery = new String [] {'Class_Name__c','Error_Message__c'};
        if(QuickbooksUtility.CheckFieldPermission('QB_Log__c','isCreateable',Null,True) 
            && QuickbooksUtility.CheckFieldPermission('QB_Log__c','isCreateable',FieldsToQuery,false))
            insert log;
        
        
    }
    
    public void LogError(string content, Exception ex) {
        QB_Log__c log = new QB_Log__c();
        log.Class_Name__c = Logger;
        log.Error_Message__c = content;
        string body = 'MESSAGE:' + ex.getMessage() + '\r\n CAUSE:' +ex.getCause() + '\r\nLINE:' + ex.getLineNumber() + '\r\nSTACK:' + ex.getStackTraceString();
        log.Exception__c = body;
        
        String [] FieldsToQuery = new String [] {'Class_Name__c','Error_Message__c','Exception__c'};
        if(QuickbooksUtility.CheckFieldPermission('QB_Log__c','isCreateable',Null,True)
            && QuickbooksUtility.CheckFieldPermission('QB_Log__c','isCreateable',FieldsToQuery,false))
            insert log;
        
        
        
    } 
}
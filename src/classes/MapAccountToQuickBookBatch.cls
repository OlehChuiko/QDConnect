/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration class for Account Synch

*/
global with sharing class MapAccountToQuickBookBatch implements Database.Batchable<Account>, Database.AllowsCallouts,Database.Stateful {
    List<Account> ListToUpdate= new List<Account>();
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings(); 
    Set<id> recordsIdSet=new Set<id>();
    
    public MapAccountToQuickBookBatch(){}
    public MapAccountToQuickBookBatch(Set<id> recordsId){
        
        recordsIdSet=recordsId;
    }
    global List<Account> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'id'};
        String [] FieldsToQuery2 = new String [] {'AccountId','StageName'};
        List<Account> newAccList=new List<Account>();
        if(!QuickbooksUtility.CheckFieldPermission('account','isAccessible',FieldsToQuery,False) 
            || !QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery2,False)){
            return newAccList;
        }
        
        String query='select id from Account where ';
        if(!recordsIdSet.isEmpty()){
            query+= ' ID IN : recordsIdSet';
        }else{
            query+= ' ID IN (SELECT AccountId FROM opportunity where StageName=\'Closed Won\') ';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            try{
                for(Account scopeRecord : scope)
                {
                    
                        Account acc=MapAccountToQuickBookController.createAccountQB(scopeRecord.Id);
                        if(acc!=Null){
                            ListToUpdate.add(acc);
                        }
                    
                }
                String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
                if(QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery,False)
                    && QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True))
                    Database.update(ListToUpdate,False);
                else
                    QB_Logger.GetLogger('MapAccountToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapAccountToQuickBookBatch for record : '+scope);
            }catch(Exception e){
                QB_Logger.GetLogger('MapAccountToQuickBookBatch').LogError('Error in  Execute method in MapAccountToQuickBookBatch for record : '+scope, e);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}
/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration.

*/
trigger AccountTrigger on Account (after update) {
    if (!System.isFuture() && !System.isBatch() && !QBConnectSyncUtility.isAccountManualSync){
        try{
            QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null && serviceObject.IsSetUpComplete__c){
                Set<id> recordsIdSet=new Set<id>();
                for(Account acc: Trigger.New){
                    if(String.isNotBlank(acc.QB_Id__c) && (acc.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
                        recordsIdSet.add(acc.id);
                    }
                }
                if(!recordsIdSet.isEmpty()){
                    Database.executeBatch(new MapAccountToQuickBookBatch(recordsIdSet),1);
                }
            }
        }catch(Exception e){
            QB_Logger.GetLogger('AccountTrigger').LogError('Error in AccountTrigger', e);
        }
    }
}
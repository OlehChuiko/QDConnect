/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration.

*/
trigger ProductTrigger on Product2(after update) {
    if (!System.isFuture() && !System.isBatch() && !QBConnectSyncUtility.isProductManualSync){
        try{
            QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null && serviceObject.IsSetUpComplete__c){
                Database.executeBatch(new MapItemToQuickBookBatch(trigger.newMap.keySet()),1);
            }
        }catch(Exception e){
            QB_Logger.GetLogger('ProductTrigger').LogError('Error in ProductTrigger', e);
        }
    }
}
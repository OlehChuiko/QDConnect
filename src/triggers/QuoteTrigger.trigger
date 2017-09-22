/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration.

*/
trigger QuoteTrigger on Quote(after insert, after update) {
    if (!System.isFuture() && !System.isBatch() && !QBConnectSyncUtility.isQuoteManualSync){
        try{
            QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null && serviceObject.IsSetUpComplete__c){
                Database.executeBatch(new MapInvoiceToQuickBookBatch(trigger.newMap.keySet()) ,10);
            }
        }catch(Exception e){
            QB_Logger.GetLogger('QuoteTrigger').LogError('Error in QuoteTrigger', e);
        }
    }
}
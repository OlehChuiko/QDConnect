/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration.

*/
trigger OpportunityTrigger on Opportunity (after insert, after update) {
    if (!System.isFuture() && !System.isBatch() && !QBConnectSyncUtility.isOppManualSync){
        try{
            QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();
            if(serviceObject!=Null && serviceObject.IsSetUpComplete__c){
                Set<id> recordsIdSet=new Set<id>();
                for(Opportunity opp: Trigger.New){

                    if(opp.StageName =='Closed Won' && opp.QuickBook_Auto_Sync__c){
                        recordsIdSet.add(opp.id);
                    }
                }

                if(!recordsIdSet.isEmpty()){
                    Database.executeBatch(new MapOpportunityToQuickBookBatch(recordsIdSet),1);
                }
            }
        }catch(Exception e){
            QB_Logger.GetLogger('OpportunityTrigger').LogError('Error in OpportunityTrigger', e);
        }
    }
}
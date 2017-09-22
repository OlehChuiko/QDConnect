/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Scheduler class for Opportunity Synch

*/
global with sharing class MapOpportunityToQuickBookBatch implements Database.Batchable<Opportunity>, Database.AllowsCallouts,Database.Stateful,Schedulable {
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
    List<Opportunity> ListToUpdate= new List<Opportunity>();
    List<Opportunity> ListToUpdateAutoSync= new List<Opportunity>();
    List<Payment__c> ListToUpsert= new List<Payment__c>();
    Set<id> recordsIdSet=new Set<id>();
        
    public MapOpportunityToQuickBookBatch(){}
    public MapOpportunityToQuickBookBatch(Set<id> recordsId){
        recordsIdSet=recordsId;
    }
    global List<Opportunity> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'QB_Id__c','id','StageName'};
        List<Opportunity> newList=new List<Opportunity>();
        if(!QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery,False)){
            QB_Logger.GetLogger('MapOpportunityToQuickBookBatch').LogError('Insufficient access on opportunity: Error in  start method in MapOpportunityToQuickBookBatch');
            return newList;
        }
        String query='SELECT id,QB_Id__c FROM Opportunity where ';
        if(!recordsIdSet.isEmpty()){
            query+= ' ID IN : recordsIdSet';
        }else{
            query+= ' StageName=\'Closed Won\' ';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            try{
                for(Opportunity scopeRecord : scope)
                {
                    Opportunity opp=MapOpportunityToQuickBookController.createOppQB(scopeRecord.Id);
                    if(opp!=Null){
                        ListToUpdate.add(opp);
                    }
                    //Make auto sync true for all closed won opp 
                    scopeRecord.QuickBook_Auto_Sync__c=true;
                    ListToUpdateAutoSync.add(scopeRecord);
                    
                    
                    if(String.isNotBlank(scopeRecord.QB_Id__c) && (scopeRecord.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
                        ListToUpsert.addAll(MapPaymentToQuickBookController.readAllPaymentsQB(scopeRecord,Null));
                    }
                    
                }
                
                String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
                String [] FieldsToQuery3 = new String [] {'QB_Id__c','Total_Amount__c','Transaction_Date__c','QB_Job_Id__c','PaymentRefNum__c','Last_Sync_Date__c'};
                
                if(QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
                    Database.update(ListToUpdate,False);
                else
                    QB_Logger.GetLogger('MapOpportunityToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapOpportunityToQuickBookBatch for record : '+scope);

                ListToUpdate.clear();
                
                if(!MapOpportunityToQuickBookController.isAccountUpdatedMap.isEmpty()){
                    
                    if(QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false))
                        update MapOpportunityToQuickBookController.isAccountUpdatedMap.values();
                    else
                        QB_Logger.GetLogger('MapOpportunityToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapOpportunityToQuickBookBatch for record : '+scope);

                    MapOpportunityToQuickBookController.isAccountUpdatedMap.clear();
                }
                if(ListToUpsert.isEmpty() && QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',Null,True) 
                    && QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',Null,True)
                    && QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',FieldsToQuery3,false)
                    && QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',FieldsToQuery3,false))

                    Database.upsert(ListToUpsert,Payment__c.Fields.QB_Id__c,False);
                    
            }catch(Exception e){
                QB_Logger.GetLogger('MapOpportunityToQuickBookBatch').LogError('Error in Execute method in MapOpportunityToQuickBookBatch for record'+scope, e);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        try{
            String [] FieldsToQuery2 = new String [] {'QuickBook_Auto_Sync__c'};
            if(QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
                Database.update(ListToUpdateAutoSync,False);
            //If Sync all data is running, then start next batch here.
            if(recordsIdSet.isEmpty()){
                DataBase.executeBatch(new MapCustomInvoiceToQuickBookBatch(),1);
            }
        }catch(Exception e){
            QB_Logger.GetLogger('MapOpportunityToQuickBookBatch').LogError('Error finish method in MapOpportunityToQuickBookBatch', e);
        }
    }
    
    //For schedulers
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new MapOpportunityToQuickBookBatch() ,1);
    }
    
}
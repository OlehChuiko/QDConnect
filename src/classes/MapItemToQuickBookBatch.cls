/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Scheduler class for Product2 Synch

*/
global with sharing class MapItemToQuickBookBatch implements Database.Batchable<Product2>, Database.AllowsCallouts,Database.Stateful,Schedulable {
    List<Product2> ListToUpdate= new List<Product2>();
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
    Set<id> recordsIdSet=new Set<id>();
    public MapItemToQuickBookBatch(){}
    public MapItemToQuickBookBatch(Set<id> recordsId){
        
        recordsIdSet=recordsId;
    }
    global List<Product2> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'id'};
        List<Product2> newList=new List<Product2>();
        if(!QuickbooksUtility.CheckFieldPermission('Product2','isAccessible',FieldsToQuery,False)){
            return newList;
        }
        String query='SELECT id FROM Product2 ';
        if(!recordsIdSet.isEmpty()){
            query+= ' where ID IN : recordsIdSet';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            try{
                for(Product2 scopeRecord : scope)
                {
                    
                        Product2 prod=MapItemToQuickBookController.createItem(scopeRecord.Id);
                        if(prod!=Null){
                            ListToUpdate.add(prod);
                        }
                        if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount))
                            serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                        if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount))
                            serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                
                }
                
                String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
                String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
                
                if(QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false))
                    Database.update(ListToUpdate,False);
                else
                    QB_Logger.GetLogger('MapItemToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapItemToQuickBookBatch for record : '+scope);
                
                ListToUpdate.clear();
                
                if(QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false))
                    update serviceObject;
                else
                    QB_Logger.GetLogger('MapItemToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapItemToQuickBookBatch for record : '+scope);
                
                
                MapItemToQuickBookController.IncomeAccount='';
                MapItemToQuickBookController.ExpenseAccount='';
            }catch(Exception e){
                QB_Logger.GetLogger('MapItemToQuickBookBatch').LogError('Error Execute method in MapItemToQuickBookBatch for record : '+scope, e);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    //For schedulers
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new MapItemToQuickBookBatch() ,1);
    }
    
}
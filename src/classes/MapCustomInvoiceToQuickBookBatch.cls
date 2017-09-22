/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Scheduler class for Invoice__c Synch

*/
global with sharing class MapCustomInvoiceToQuickBookBatch implements Database.Batchable<Invoice__c>, Database.AllowsCallouts,Database.Stateful,Schedulable {
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
    List<Invoice__c> ListToUpdate= new List<Invoice__c>();
    Set<id> recordsIdSet=new Set<id>();
    
    public MapCustomInvoiceToQuickBookBatch(){}
    public MapCustomInvoiceToQuickBookBatch(Set<id> recordsId){
        recordsIdSet=recordsId;
    }
    
    global List<Invoice__c> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'id'};
        String [] FieldsToQuery2 = new String [] {'StageName','QuickBook_Auto_Sync__c'};
        List<Invoice__c> newList=new List<Invoice__c>();
        if(!QuickbooksUtility.CheckFieldPermission('Invoice__c','isAccessible',FieldsToQuery,False) 
            || !QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery2,False)){
            return newList;
        }
        
        String query='SELECT Id FROM Invoice__c where opportunity__r.StageName=\'Closed Won\' AND  opportunity__r.QuickBook_Auto_Sync__c=true ';
        if(!recordsIdSet.isEmpty()){
            query+= ' AND ID IN : recordsIdSet ';
        }
        return Database.query(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            try{
                for(Invoice__c scopeRecord : scope)
                {
                    
                    Invoice__c invObj=MapCustomInvoiceToQuickBookController.createInvoiceQB(scopeRecord.Id);
                    if(invObj!=Null){
                        ListToUpdate.add(invObj);
                    }
                }
                
                String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c','Balance__c','Invoice_Number__c'};
                String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
                String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
                if(QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',FieldsToQuery,false))
                    Database.update(ListToUpdate,False);
                else
                    QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on Invoice__c : Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                
                ListToUpdate.clear();
                
                if(!MapCustomInvoiceToQuickBookController.prodList.isEmpty()){
                    //Insert New Products
                    if(QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapCustomInvoiceToQuickBookController.prodList.values(),False);
                    else
                        QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on Product2: Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                    
                    MapCustomInvoiceToQuickBookController.prodList.clear();
                    //Insert New IncomeAccount
                    if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount)){
                        serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                    } 
                    if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount)){
                        serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                    }
                    if(QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false))
                        update serviceObject;
                    else
                        QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on QuickBookAuthDetails1__c: Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                    
                    MapItemToQuickBookController.IncomeAccount='';
                    MapItemToQuickBookController.ExpenseAccount='';
                    
                }
                if(!MapCustomInvoiceToQuickBookController.accountList.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapCustomInvoiceToQuickBookController.accountList.values(),False);
                    else
                        QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on account: Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                    

                    MapCustomInvoiceToQuickBookController.accountList.clear();
                }
                
                if(!MapCustomInvoiceToQuickBookController.OpportunityList.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapCustomInvoiceToQuickBookController.OpportunityList.values(),False);
                    else
                        QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on opportunity : Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                    
                    MapCustomInvoiceToQuickBookController.OpportunityList.clear();
                }
                if(!MapCustomInvoiceToQuickBookController.SalesTermsmap.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapCustomInvoiceToQuickBookController.SalesTermsmap.values(),False);
                    else
                        QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Insufficient access on terms: Error in  Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope);
                    
                    
                    MapCustomInvoiceToQuickBookController.SalesTermsmap.clear();
                }
            }catch(Exception e){
                QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Error Execute method in MapCustomInvoiceToQuickBookBatch for record : '+scope, e);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        try{
            //If Sync all data is running, then start next batch here.
            if(recordsIdSet.isEmpty()){
                DataBase.executeBatch(new MapInvoiceToQuickBookBatch(),1);
            }
        }catch(Exception e){
                QB_Logger.GetLogger('MapCustomInvoiceToQuickBookBatch').LogError('Error  in Final method MapCustomInvoiceToQuickBookBatch', e);
        }
    }
    
    //For schedulers
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new MapCustomInvoiceToQuickBookBatch() ,1);
    }
    
}
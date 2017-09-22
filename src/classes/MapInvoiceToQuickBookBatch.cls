/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Scheduler class for Quote Synch

*/
global with sharing class MapInvoiceToQuickBookBatch implements Database.Batchable<Quote>, Database.AllowsCallouts,Database.Stateful,Schedulable {
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings(); 
    List<Quote> ListToUpdateQuote= new List<Quote>();
    Set<id> recordsIdSet=new Set<id>();
    public MapInvoiceToQuickBookBatch(){}
    public MapInvoiceToQuickBookBatch(Set<id> recordsId){
        recordsIdSet=recordsId;
    }
    
    global List<Quote> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'id'};
        String [] FieldsToQuery2 = new String [] {'StageName','QuickBook_Auto_Sync__c'};
        List<Quote> newList=new List<Quote>();
        if(!QuickbooksUtility.CheckFieldPermission('quote','isAccessible',FieldsToQuery,False) 
            || !QuickbooksUtility.CheckFieldPermission('opportunity','isAccessible',FieldsToQuery2,False)){
            return newList;
        }
        
        String query='SELECT Id FROM quote where opportunity.StageName=\'Closed Won\' AND  opportunity.QuickBook_Auto_Sync__c=true AND QB_Object_Type__c=\'Invoice\' ';
        if(!recordsIdSet.isEmpty()){
            query+= ' AND ID IN : recordsIdSet ';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext BC, List<Quote> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            try{
                for(Quote scopeRecord : scope)
                {
                    quote quoteObj=MapInvoiceToQuickBookController.createInvoiceQB(scopeRecord.Id);
                    if(quoteObj!=Null){
                        ListToUpdateQuote.add(quoteObj);
                    }
                }
                
                
                String [] FieldsToQuery = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c','QB_Balance__c','EstimateNumber__c'};
                String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
                String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
                
                if(QuickbooksUtility.CheckFieldPermission('quote','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('quote','isUpdateable',FieldsToQuery,false))
                    Database.update(ListToUpdateQuote,False);
                else
                    QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                
                ListToUpdateQuote.clear();
                
                if(!MapInvoiceToQuickBookController.prodList.isEmpty()){
                    //Insert New Products
                    if(QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapInvoiceToQuickBookController.prodList.values(),False);
                    else
                        QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                    
                    
                    MapInvoiceToQuickBookController.prodList.clear();
                    if(String.isNotBlank(MapItemToQuickBookController.IncomeAccount)){
                        serviceObject.IncomeAccountRef__c=MapItemToQuickBookController.IncomeAccount;
                    } 
                    if(String.isNotBlank(MapItemToQuickBookController.ExpenseAccount)){
                        serviceObject.ExpenseAccountRef__c=MapItemToQuickBookController.ExpenseAccount;
                    }
                    if(QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false))
                        update serviceObject;
                    else
                        QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                    
                    
                    MapItemToQuickBookController.IncomeAccount='';
                    MapItemToQuickBookController.ExpenseAccount='';
                }
                if(!MapInvoiceToQuickBookController.accountList.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('account','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('account','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapInvoiceToQuickBookController.accountList.values(),False);
                    else
                        QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                    
                    MapInvoiceToQuickBookController.accountList.clear();
                }
                if(!MapInvoiceToQuickBookController.OpportunityList.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('opportunity','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapInvoiceToQuickBookController.OpportunityList.values(),False);
                    else
                        QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                    
                    
                    MapInvoiceToQuickBookController.OpportunityList.clear();
                }
                 if(!MapInvoiceToQuickBookController.SalesTermsmap.isEmpty()){
                    if(QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('Terms__c','isUpdateable',FieldsToQuery2,false))
                        Database.update(MapInvoiceToQuickBookController.SalesTermsmap.values(),False);
                    else
                        QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Insufficient access : Error in  Execute method in MapInvoiceToQuickBookBatch for record : '+scope);
                    
                    MapInvoiceToQuickBookController.SalesTermsmap.clear();
                }
            }catch(Exception e){
                QB_Logger.GetLogger('MapInvoiceToQuickBookBatch').LogError('Error Execute method in MapInvoiceToQuickBookBatch for record : '+scope, e);
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        //If Sync all data is running, then update last sync here.
        String [] FieldsToQuery = new String [] {'Last_Sync_All_Sf_To_Qb__c'};
        if(recordsIdSet.isEmpty() && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false)){
            serviceObject.Last_Sync_All_Sf_To_Qb__c=system.now();
            update serviceObject;
        }
    }
    
    //For schedulers
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new MapInvoiceToQuickBookBatch() ,1);
    }
    
}
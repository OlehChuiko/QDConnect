/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
global with sharing class QuickBookInvoiceScheduler  Implements Database.Batchable<Opportunity>, Database.AllowsCallouts,Database.Stateful,Schedulable 
{
    QuickBookAuthDetails1__c serviceObject=QuickbooksUtility.getServiceSettings();
    String SchedulerRunTime='';
    public QuickBookInvoiceScheduler(){}
    public QuickBookInvoiceScheduler(String SchedulerTime){
        SchedulerRunTime=SchedulerTime;
    }
    global List<Opportunity> start(Database.BatchableContext BC) {
        String [] FieldsToQuery = new String [] {'QB_Id__c','id'};
        if(QuickbooksUtility.CheckFieldPermission('Opportunity','isAccessible',FieldsToQuery,False)){
            return DataBase.query('select id,QB_Id__c from Opportunity where QB_Id__c!= null');
        }else{
            QB_Logger.GetLogger('QuickBookInvoiceScheduler').LogError('Insufficient access : Error in QuickBookInvoiceScheduler');
            return null;
        }
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        if(scope != null && serviceObject!=Null && serviceObject.IsSetUpComplete__c && serviceObject.Paid_Version__c)
        {
            for(Opportunity scopeRecord : scope)
            {
                try{
                    List<Invoice__c> ListToUpsertInvoice= new List<Invoice__c>();
                    List<Payment__c> ListToUpsertPayment= new List<Payment__c>();
                    
                    ListToUpsertInvoice=GetinvoicesFromQuickbooksController.readAllInvoicesQB(scopeRecord,SchedulerRunTime);
                    ListToUpsertPayment=MapPaymentToQuickBookController.readAllPaymentsQB(scopeRecord,SchedulerRunTime);
                    
                    String [] FieldsToQuery3 = new String [] {'QB_Id__c','Total_Amount__c','Transaction_Date__c','QB_Job_Id__c','PaymentRefNum__c','Last_Sync_Date__c'};
                    String [] FieldsToQuery = new String [] {'QB_Id__c','Invoice_Date__c','Invoice_Number__c','BillEmail__c','DueDate__c','Balance__c','Last_Sync_Date__c','QB_Error__c','Shipment_Tracking_Number__c','Ship_Date__c','Private_Note__c','Copy_Address_from__c','CustomerMemo__c','BillingName__c','BillingStreet__c','BillingState__c','BillingCity__c','BillingCountry__c','BillingPostalCode__c','ShippingName__c','ShippingStreet__c','ShippingState__c','ShippingCity__c','ShippingCountry__c','ShippingPostalCode__c','Shipping_Method__c'};
            
                    if(ListToUpsertInvoice!= Null && !ListToUpsertInvoice.isEmpty() 
                        && QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True)  
                        && QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',Null,True)
                        && QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',FieldsToQuery,False)
                        && QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',FieldsToQuery,False))
                    {
                        Database.upsert(ListToUpsertInvoice,Invoice__c.Fields.QB_Id__c,False);
                    }
                    
                    
                    if(ListToUpsertPayment!= Null && !ListToUpsertPayment.isEmpty() 
                        && QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',Null,True)  
                        && QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',Null,True)
                        && QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',FieldsToQuery3,false)
                        && QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',FieldsToQuery3,false))
                    {
                        Database.upsert(ListToUpsertPayment,Payment__c.Fields.QB_Id__c,False);
                    }
                    
                    if(!QuickbooksUtility.CheckFieldPermission('invoice__c','isUpdateable',Null,True)  
                         || !QuickbooksUtility.CheckFieldPermission('Payment__c','isUpdateable',Null,True)  
                         || !QuickbooksUtility.CheckFieldPermission('Payment__c','isCreateable',Null,True)  
                         || !QuickbooksUtility.CheckFieldPermission('invoice__c','isCreateable',Null,True))
                    {
                        QB_Logger.GetLogger('QuickBookInvoiceScheduler').LogError('Insufficient access : Error in QuickBookInvoiceScheduler for record : '+scope);
                    }
                }catch(Exception e){
                    QB_Logger.GetLogger('QuickBookInvoiceScheduler').LogError('Error in QuickBookInvoiceScheduler for record : '+scope, e);
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC)
    {
       //If Sync all data is running, then update last sync here.
       if(SchedulerRunTime==''){
            serviceObject.Last_Sync_All_Qb_To_Sf__c = system.now();
            if(QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True))
                update serviceObject;
            else
                QB_Logger.GetLogger('QuickBookInvoiceScheduler').LogError('Insufficient access : Error in  finish method in QuickBookInvoiceScheduler');
            
       }
    }
    //For Scheduler
   global  void execute(SchedulableContext sc)
    {
        try{
            //Execute Batch
            DataBase.executeBatch(new QuickBookInvoiceScheduler(getSchedulerTime()),1);
            
             //To delete completed apex scheduled jobs for which state is DELETED
            for( CronTrigger c:[Select State,Id,EndTime,CronExpression From CronTrigger where NextFireTime=null  AND State='DELETED' Limit 100]){
                System.abortJob(c.id);
            }
            //Schedule next run 
              doScheduling();
        }catch(Exception e){
            QB_Logger.GetLogger('QuickBookInvoiceScheduler').LogError('Error in QuickBookInvoiceScheduler', e);
        }
            
    }
    public void doScheduling(){
            dateTime dt;
            if(String.isNotBlank(serviceObject.AutoRunDuration__c)){
                string selectedDurationForSchedulers=serviceObject.AutoRunDuration__c;
                dt=System.now().addMinutes(Integer.valueOf(selectedDurationForSchedulers));
            }else{
                dt=System.now().addMinutes(Integer.valueOf(System.Label.QBPaymentInvoiceSchedulerDuration));
            }
            String Csec,Cmin,Chr,Cday,Cmonth,CYear;
            Csec=String.valueof(dt.second());
            Cmin=String.valueof(dt.minute());
            Chr=String.valueof(dt.hour());
            Cday=String.valueof(dt.day());
            Cmonth=String.valueof(dt.month());
            CYear=String.valueof(dt.Year());
            String SchTimer=Csec+' '+Cmin+' '+Chr+' '+Cday+' '+Cmonth+' ? '+CYear;
            QuickBookInvoiceScheduler cas = new QuickBookInvoiceScheduler();
            system.schedule('QuickBooksInvoicePaymentScheduler: Running at '+System.Now(), SchTimer, cas);
   }
    //Set Time for which scheduler fetched records
    public string getSchedulerTime(){
        String SchTimer='';
            dateTime dt;
            if(String.isNotBlank(serviceObject.AutoRunDuration__c)){
                string selectedDurationForSchedulers=serviceObject.AutoRunDuration__c;
                dt=System.now().addMinutes(Integer.valueOf('-'+selectedDurationForSchedulers));
            }else{
                dt=System.now().addMinutes(Integer.valueOf('-'+System.Label.QBPaymentInvoiceSchedulerDuration));
            }
            String Csec,Cmin,Chr,Cday,Cmonth,CYear;
            Csec=String.valueof(dt.second());
            Cmin=String.valueof(dt.minute());
            Chr=String.valueof(dt.hour());
            Cday=String.valueof(dt.day());
            Cmonth=String.valueof(dt.month());
            CYear=String.valueof(dt.Year());
            SchTimer=CYear+'-'+fixTime(Cmonth)+'-'+fixTime(Cday)+'T'+fixTime(Chr)+'%3A'+fixTime(Cmin)+'%3A'+fixTime(Csec);
        return SchTimer;
    }
    public string fixTime(string str){
        if(str.length()>1){
          return str;
        }else{
          return ('0'+str);
        }
    }
}
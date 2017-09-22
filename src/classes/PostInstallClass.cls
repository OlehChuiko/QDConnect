/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration Post Install script to create custom setting record on Package install.

*/
global with sharing class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        try{
            if(context.previousVersion() == null){
                String [] FieldsToQuery3 = new String [] {'Name__c','Consumer_Key__c','Consumer_Secret__c','Access_Token_URL__c','Application_Token__c','Authorization_URL__c','Request_Token_URL__c','Paid_Version__c'};
                String [] FieldsToQuery4 = new String [] {'Name','Mapping_Object_Name__c'};
                if(!QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)  
                    || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isCreateable',Null,True)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',Null,True)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',Null,True)
                    
                    || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false)  
                    || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isCreateable',FieldsToQuery3,false)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isCreateable',FieldsToQuery4,false)
                    || !QuickbooksUtility.CheckFieldPermission('QB_Fields_Mapping__c','isUpdateable',FieldsToQuery4,false))
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficient access'));
                    QB_Logger.GetLogger('PostInstallClass').LogError('Insufficient access on QB_Fields_Mapping__c or QuickBookAuthDetails1__c object :  Error in PostInstallClass');
                }else{
                
                    QuickBookAuthDetails1__c QuickBookAuth = new QuickBookAuthDetails1__c(Name__c='QuickBookAuthDetails',Consumer_Key__c='qyprddOv2oSP4QrPnmPe21HF4exvk1',Consumer_Secret__c='Hz46wSvK9fgsB7phFef7QH4QnnxY4tO2lcqoSWaa',Access_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_access_token',Application_Token__c='3c6452d6b7ca9b416eb8680b954b3a3ee45a',Authorization_URL__c='https://appcenter.intuit.com/Connect/Begin',Request_Token_URL__c='https://oauth.intuit.com/oauth/v1/get_request_token');
                    QuickBookAuth.Paid_Version__c=true;
                    
                    upsert QuickBookAuth Name__c;
                  
                    QB_Fields_Mapping__c mappingObject1= new QB_Fields_Mapping__c(Name='Invoice',Mapping_Object_Name__c='Invoice');
                    upsert mappingObject1 Mapping_Object_Name__c;
                    
                    //Scheduler class to delete QB Logs weekly
                    String strJobName2 = 'QBDeleteErrorLogBatch Running at '+string.valueOf(System.Now());
                    String strSchedule2 = '0 0 0 ? * 1 * ';
                    System.schedule(strJobName2, strSchedule2, new QBDeleteErrorLogBatch());
                }
            }
        }catch(Exception e){
            QB_Logger.GetLogger('PostInstallClass').LogError('Error in PostInstallClass', e);
        }
        
    }
    
}
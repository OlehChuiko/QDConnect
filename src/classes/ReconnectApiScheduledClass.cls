/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
global with sharing class ReconnectApiScheduledClass Implements Schedulable, Database.AllowsCallouts
{
   
   global  void execute(SchedulableContext sc)
    {
        ReconnectApi();
        //To delete completed apex scheduled jobs for which state is DELETED
        for( CronTrigger c:[Select State,Id,EndTime,CronExpression From CronTrigger where NextFireTime=null  AND State='DELETED' Limit 100]){
            System.abortJob(c.id);
        }
    }
    @future(callout=true)
    public static void ReconnectApi(){
        QuickBookAuthDetails1__c serviceObject= QuickbooksUtility.getServiceSettings();
        String errorEmailBody='';
        try{
            String endpoint = 'https://appcenter.intuit.com/api/v1/connection/reconnect';

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint(endpoint);
            req.setMethod('GET');   
            req = QuickbooksAPI.signRequest(req);
            req.setHeader('Accept' , 'application/json');
            req.setHeader('content-type', 'application/json');
                
            HttpResponse res;
            res = http.send(req); 
            
            if(res.getStatusCode()==200){
                QuickbooksUtility.QbReconnectResponseJSON responseObj= (QuickbooksUtility.QbReconnectResponseJSON) System.JSON.deserialize(res.getBody(), QuickbooksUtility.QbReconnectResponseJSON.class);
                if(responseObj.ErrorCode==0){
                
                    serviceObject.OAuth_Token__c = responseObj.OAuthToken;
                    serviceObject.OAuth_Token_Secret__c = responseObj.OAuthTokenSecret;
                    serviceObject.Last_Token_Refresh_Date__c=Date.Today();
                    if(string.isNotBlank(serviceObject.OAuth_Token__c) && string.isNotBlank(serviceObject.OAuth_Token_Secret__c)){
                        serviceObject.IsSetUpComplete__c=true;
                    }
                    
                     if(String.isNotBlank(serviceObject.ReconnectCronJobId__c)){
                        for( CronTrigger c:[Select Id From CronTrigger where id =:serviceObject.ReconnectCronJobId__c]){
                            System.abortJob(c.id);
                        }
                        serviceObject.ReconnectCronJobId__c='';
                    }
                    //Schedule job to refresh token between 150-180 Days window.
                        Date dt= Date.Today().addDays(160);
                        String day = string.valueOf(dt.day());
                        String month = string.valueOf(dt.month());
                        String year = string.valueOf(dt.year());
                        
                        String strJobName = 'QBReconnectJob-' +day+ '_' + month + '_' + year;
                        String strSchedule = '0 ' + 0 + ' ' + 1 + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                        
                        serviceObject.ReconnectCronJobId__c=System.schedule(strJobName ,strSchedule, new ReconnectApiScheduledClass());
                    
                    
                    String [] FieldsToQuery = new String [] {'ReconnectCronJobId__c','OAuth_Token__c','OAuth_Token_Secret__c','Last_Token_Refresh_Date__c','IsSetUpComplete__c'};           
                    if(QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True) && QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery,false)){    
                        update serviceObject;
                    }else{
                        QB_Logger.GetLogger('ReconnectApiScheduledClass').LogError('Insufficient access on QuickBookAuthDetails1__c : Error while refreshing token from QuickBooks');
                        errorEmailBody='Error while refreshing token from QuickBooks :Insufficient access on QuickBookAuthDetails1__c';
                    }
                    
                }else if(responseObj.ErrorCode==212){
                    errorEmailBody='Error while refreshing token from QuickBooks as The request is made outside the 30-day window to reconnect. Please try later.';
                }else if(responseObj.ErrorCode==270){
                    errorEmailBody='Error while refreshing token from QuickBooks as the old token has expired. Please complete the QuickBooks set up again.';
                }else{
                    errorEmailBody='Error while refreshing token from QuickBooks :'+responseObj.ErrorMessage;
                }
            }
        }catch(Exception e) {
            errorEmailBody='Error while refreshing token from QuickBooks :'+e.getMessage();
            QB_Logger.GetLogger('ReconnectApiScheduledClass').LogError('Error while refreshing token from QuickBooks', e);
        }
        if(String.isNotBlank(errorEmailBody)){
           
            User current_user=[SELECT Email FROM User WHERE Id= :UserInfo.getUserId()] ;
     
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string [] toaddress= New string[]{current_user.Email};
            email.setSubject('QuickBooks API Reconnect Scheduler Status');
            email.setPlainTextBody('Hi, \r\n'+errorEmailBody+'\r\n\r\nThanks.');
            email.setToAddresses(toaddress);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        }
    }
    
}
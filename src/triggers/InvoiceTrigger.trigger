/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration.

*/
trigger InvoiceTrigger on Invoice__c (before insert,before update,after insert, after update) {
    if (!System.isFuture() && !System.isBatch() && !QBConnectSyncUtility.isInvoiceManualSync){
        try{    
            //For Copying address fields from Account to Invoice
            if(Trigger.isBefore){
                map<Id,List<Invoice__c>> oppInvoiceMap=new map<Id,List<Invoice__c>>();
                map<Id,List<Opportunity>> AccOppMap=new map<Id,List<Opportunity>>();
                For(Invoice__c inv : Trigger.New){
                    if(!oppInvoiceMap.containsKey(inv.Opportunity__c)){
                        oppInvoiceMap.put(inv.Opportunity__c,new List<Invoice__c>());
                    }
                    oppInvoiceMap.get(inv.Opportunity__c).add(inv);
                }
                
                for(Opportunity opp : [select Id,AccountId,(SELECT BillingCity,BillingCountry,BillingName,BillingPostalCode,BillingState,BillingStreet,ShippingCity,ShippingCountry,ShippingName,ShippingPostalCode,ShippingState,ShippingStreet FROM Quotes ORDER BY CreatedDate DESC LIMIT 1) from Opportunity where id in : oppInvoiceMap.keyset()]){
                    if(!AccOppMap.containsKey(opp.AccountId)){
                        AccOppMap.put(opp.AccountId,new List<Opportunity>());
                    }
                    AccOppMap.get(opp.AccountId).add(opp);
                }
                List<Account> AccountList= [select Name,billingStreet,BillingCity,billingState,BillingCountry,BillingPostalCode,ShippingStreet,ShippingState,ShippingCity,ShippingCountry,ShippingPostalCode from Account where Id in :AccOppMap.keySet()]; 
                For(Account acc : AccountList){
                    For(Opportunity opp : AccOppMap.get(acc.id)){
                        For(Invoice__c inv : oppInvoiceMap.get(opp.Id)){
                            if(inv.Copy_Address_from__c=='Quote' && !opp.Quotes.isEmpty()){
                                for(Quote quot : opp.Quotes){
                                    inv.BillingName__c=quot.BillingName;
                                    inv.BillingStreet__c=quot.billingStreet;
                                    inv.BillingState__c=quot.billingState;
                                    inv.BillingCity__c=quot.BillingCity;
                                    inv.BillingCountry__c=quot.BillingCountry;
                                    inv.BillingPostalCode__c=quot.BillingPostalCode;
                                    
                                    inv.ShippingName__c=quot.ShippingName;
                                    inv.ShippingStreet__c=quot.ShippingStreet;
                                    inv.ShippingState__c=quot.ShippingState;
                                    inv.ShippingCity__c=quot.ShippingCity;
                                    inv.ShippingCountry__c=quot.ShippingCountry;
                                    inv.ShippingPostalCode__c=quot.ShippingPostalCode;
                                }
                            }else if(inv.Copy_Address_from__c=='Account' || string.isBlank(inv.BillingName__c) && string.isBlank(inv.ShippingName__c) && string.isBlank(inv.BillingPostalCode__c) && string.isBlank(inv.ShippingPostalCode__c) && string.isBlank(inv.BillingCountry__c) && string.isBlank(inv.ShippingCountry__c) && string.isBlank(inv.BillingState__c) && string.isBlank(inv.BillingState__c) && string.isBlank(inv.BillingCity__c) && string.isBlank(inv.ShippingStreet__c) && string.isBlank(inv.ShippingState__c) && string.isBlank(inv.ShippingCity__c)){
                                    inv.BillingName__c=acc.name;
                                    inv.BillingStreet__c=acc.billingStreet;
                                    inv.BillingState__c=acc.billingState;
                                    inv.BillingCity__c=acc.BillingCity;
                                    inv.BillingCountry__c=acc.BillingCountry;
                                    inv.BillingPostalCode__c=acc.BillingPostalCode;
                                    
                                    inv.ShippingName__c=acc.name;
                                    inv.ShippingStreet__c=acc.ShippingStreet;
                                    inv.ShippingState__c=acc.ShippingState;
                                    inv.ShippingCity__c=acc.ShippingCity;
                                    inv.ShippingCountry__c=acc.ShippingCountry;
                                    inv.ShippingPostalCode__c=acc.ShippingPostalCode;
                            }
                        }
                    }
                }
            }else{
                QuickBookAuthDetails1__c serviceObject = QuickbooksUtility.getServiceSettings();
                if(serviceObject!=Null && serviceObject.IsSetUpComplete__c){
                    //For real time update to QB
                    Database.executeBatch(new MapCustomInvoiceToQuickBookBatch(trigger.newMap.keySet()) ,1);
                }
            }
        }catch(Exception e){
            QB_Logger.GetLogger('InvoiceTrigger').LogError('Error in InvoiceTrigger', e);
        }
    }
}
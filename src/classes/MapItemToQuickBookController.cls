/*
Company Name: CloudBuilders
Developer Name : Sunny Ravesh
Description : QuickBooks Integration

*/
public with sharing class MapItemToQuickBookController {
    public Boolean isDisplayed{get;set;}
    
    private Id prodId;
    private ApexPages.StandardController stdController;
    public static QuickBookAuthDetails1__c serviceObject; 
    public static  Boolean isProductManualSync=false;
    public static string IncomeAccount;
    public static string ExpenseAccount;
    public static string QB_ID='';
    public MapItemToQuickBookController (ApexPages.StandardController stdController) {
         prodId= (Id)stdController.getRecord().id;
         this.stdController = stdController;
         isDisplayed=false;
    }
    
    public PageReference createItem(){
        try{
            isDisplayed=true;
            isProductManualSync=true;
            String [] FieldsToQuery2 = new String [] {'QB_Id__c','Last_Sync_Date__c','QB_Error__c'};
            String [] FieldsToQuery3 = new String [] {'IncomeAccountRef__c','ExpenseAccountRef__c'};
            if(!QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',Null,True) 
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',Null,True)
                || !QuickbooksUtility.CheckFieldPermission('Product2','isUpdateable',FieldsToQuery2,false)
                || !QuickbooksUtility.CheckFieldPermission('QuickBookAuthDetails1__c','isUpdateable',FieldsToQuery3,false))
            {
                QuickbooksUtility.AddPageMessages('Insufficient access.');
                return null;
            }
            Product2 prod=createItem(prodId);
            if(prod!=Null){
                update prod;
            }
            if(serviceObject!=Null){
                if(String.isNotBlank(IncomeAccount))
                    serviceObject.IncomeAccountRef__c=IncomeAccount;
                if(String.isNotBlank(ExpenseAccount))
                    serviceObject.ExpenseAccountRef__c=ExpenseAccount;
                
                update serviceObject;
            }
            
            
        }catch(Exception e){
            QuickbooksUtility.AddPageMessages(e.getMessage());
            QB_Logger.GetLogger('MapItemToQuickBookController').LogError(e.getMessage(), e);
        }
        return Null;
    }
    
    public static  Product2 createItem(Id prodId){
        string SynchToken;
        serviceObject = QuickbooksUtility.getServiceSettings();
        
        if(serviceObject==Null || !serviceObject.IsSetUpComplete__c){
             QuickbooksUtility.AddPageMessages('You are not connected to a QuickBooks Account.');
             return null;
        }
        
        String [] FieldsToQuery = new String [] {'id','Name','Description','QB_Id__c','IsActive','Last_Sync_Date__c','QB_Error__c','QB_Purchase_Description__c','QB_Quantity_On_Hand__c','QB_COGS_Amount__c'};
        String [] FieldsToQuery2 = new String [] {'id','UnitPrice'};
        if(!QuickbooksUtility.CheckFieldPermission('Product2','isAccessible',FieldsToQuery,False) || !QuickbooksUtility.CheckFieldPermission('PricebookEntry','isAccessible',FieldsToQuery2,False)){
            QuickbooksUtility.AddPageMessages('Insufficient access.');
            return null;
        }
        Product2 prod=[SELECT id,Name,Description,QB_Id__c,IsActive,Last_Sync_Date__c,QB_Error__c,QB_Purchase_Description__c,QB_Quantity_On_Hand__c,QB_COGS_Amount__c,(select id,UnitPrice from PricebookEntries WHERE Pricebook2.IsStandard = true) FROM Product2 where Id =:prodId limit 1];
        
        if(prod.QB_Id__c!=Null && prod.QB_Id__c!='' && (prod.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)){
            SynchToken=readItem(prod.QB_Id__c.split('-')[1],serviceObject.Company_Id__c);
        }
        
        string reqBody=createItemDataJson(SynchToken,prod,serviceObject.Company_Id__c,serviceObject.IncomeAccountRef__c,serviceObject.ExpenseAccountRef__c);
        
        string updateOpp=((prod.QB_Id__c!=Null && prod.QB_Id__c!='' && (prod.QB_Id__c.split('-')[0]==serviceObject.Company_Id__c)) ? '?operation=update' : '');
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/item'+updateOpp;

        HttpResponse res = QuickbooksUtility.makeCalloutToQuickBooks(endpoint,reqBody);
        
        if(res.getStatusCode()==200){
                ItemJsonResponse objToSave=(ItemJsonResponse)System.JSON.deserialize(res.getBody(), ItemJsonResponse.class);
                prod.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Item.Id;
                prod.Last_Sync_Date__c=System.now();
                prod.QB_Error__c='';
                QB_ID='';
                
        }else if(res.getStatusCode()==401){
            QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
            prod.QB_Error__c='Error connecting to QuickBooks, Please verify connection setup again.';
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            if(errorObj.Fault.Error[0].Message=='Duplicate Name Exists Error'){
                QB_ID=QuickbooksUtility.QueryFromQB(serviceObject.Company_Id__c,prod.Name,'Item');
                if(string.isNotBlank(QB_ID)){
                    SynchToken=readItem(QB_ID,serviceObject.Company_Id__c);
                    string reqBody1=createItemDataJson(SynchToken,prod,serviceObject.Company_Id__c,serviceObject.IncomeAccountRef__c,serviceObject.ExpenseAccountRef__c);
                    String endpoint1 = 'https://quickbooks.api.intuit.com/v3/company/'+serviceObject.Company_Id__c+'/item?operation=update';
                    
                    HttpResponse res1 = QuickbooksUtility.makeCalloutToQuickBooks(endpoint1,reqBody1);
        
                    if(res1.getStatusCode()==200){
                        ItemJsonResponse objToSave=(ItemJsonResponse)System.JSON.deserialize(res1.getBody(), ItemJsonResponse.class);
                        prod.QB_Id__c=serviceObject.Company_Id__c+'-'+objToSave.Item.Id;
                        prod.Last_Sync_Date__c=System.now();
                        prod.QB_Error__c='';
                        QB_ID='';
                        
                        return prod;
                    }
                }
            }
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            prod.QB_Error__c=ErrorToShow;
            QuickbooksUtility.AddPageMessages('Product Error : '+ErrorToShow);
            QB_Logger.GetLogger('MapItemToQuickBookController').LogError('Product Sync callout to QB Error(Record - '+prod.id+') : '+ErrorToShow);
        }
        return prod;
    }
    public static String readItem(String prodQBId,String CompanyId){
            String SynchToken;
            String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/item/'+prodQBId;

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
                ItemJsonResponse objToSave=(ItemJsonResponse)System.JSON.deserialize(res.getBody(), ItemJsonResponse.class);
                SynchToken=objToSave.Item.SyncToken;
                if(objToSave.Item.SubItem ==True && objToSave.Item.ParentRef !=Null){
                    SynchToken+='-'+objToSave.Item.ParentRef.value;
                }
                
            }else if(res.getStatusCode()==401){
                QuickbooksUtility.AddPageMessages('Error connecting to QuickBooks, Please verify connection setup again.');
                
            }else{
                QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
                string ErrorToShow=errorObj.Fault.Error[0].Detail;
                QuickbooksUtility.AddPageMessages('Product Error : '+ErrorToShow);
            }
        return SynchToken;
          
    }
    public static string createItemDataJson(String SyncToken,Product2 prod,String CompanyId,String IncomeAcc,String ExpenseAcc){
        //Main Wrapper
        cls_Item wrap= new cls_Item();
        
        cls_IncomeAccountRef obj= new cls_IncomeAccountRef();
            if(String.isNotBlank(IncomeAcc)){
                obj.value=IncomeAcc;
            }else{
                if(String.isNotBlank(IncomeAccount))
                {
                    obj.value=IncomeAccount;
                }else{
                    IncomeAccount=QueryCOGSAccount(CompanyId,'Sales');
                    obj.value=IncomeAccount;
                }
            }
            wrap.IncomeAccountRef=obj;
            
        cls_ExpenseAccountRef obj1= new cls_ExpenseAccountRef();
            if(String.isNotBlank(ExpenseAcc)){
                obj1.value=ExpenseAcc;
            }else{
                if(String.isNotBlank(ExpenseAccount))
                {
                    obj1.value=ExpenseAccount;
                }else{
                    ExpenseAccount=QueryCOGSAccount(CompanyId,'Cost Of Goods Sold');
                    obj1.value=ExpenseAccount;
                }
            }
        
            wrap.ExpenseAccountRef=obj1;
        /*
        if(prod.QB_Id__c!=Null && prod.QB_Id__c!='' && (prod.QB_Id__c.split('-')[0]==CompanyId)){
            wrap.Id=prod.QB_Id__c.split('-')[1];
        }*/
        //If product is in Hierarchy-Update Name/SyncToken/ParentRef accordingly
        if(String.isBlank(SyncToken)){
            wrap.Name=prod.Name;
        }else{
            wrap.Id=(string.isNotBlank(QB_Id) ? QB_Id : prod.QB_Id__c.split('-')[1]);
            wrap.sparse=true;
            
            if(prod.Name.contains(':')){
                wrap.Name=prod.Name.split(':')[prod.Name.split(':').size()-1].trim();
            }else{
                wrap.Name=prod.Name;
            }
            
            if(SyncToken.contains('-')){
                cls_ParentRef parentR=new cls_ParentRef();
                parentR.value = SyncToken.split('-')[1];
                
                wrap.ParentRef=parentR;
                wrap.SubItem=true;
                wrap.SyncToken=SyncToken.split('-')[0];
            }else{
                wrap.SyncToken=SyncToken;
            }
        }
        if(prod.Description!=NULL)
            wrap.Description=prod.Description.substring(0, Math.min(prod.Description.length(), 4000));
        
        
        wrap.Active=prod.IsActive;
        wrap.Taxable=true;
        //wrap.TrackQtyOnHand=true;
        
        wrap.PurchaseDesc=prod.QB_Purchase_Description__c;
        
        if(prod.QB_Quantity_On_Hand__c!=Null){
            wrap.QtyOnHand=prod.QB_Quantity_On_Hand__c;
        }
        if(prod.QB_COGS_Amount__c!=Null){
            wrap.PurchaseCost=prod.QB_COGS_Amount__c;
        }
        if(!prod.PricebookEntries.isEmpty()){
            wrap.UnitPrice=prod.PricebookEntries[0].UnitPrice;
        }
        //Serialize this Obj
        
        return Json.serialize(wrap);
    }
    public static String QueryCOGSAccount(String CompanyId,String AccountType){
        String QB_ID1='';
        String queryStr='';
        if(AccountType=='Cost Of Goods Sold'){
            queryStr='select%20Id%20from%20Account%20where%20Name%3D%27Cost%20of%20Goods%20Sold%27';
        }else if(AccountType=='Sales'){
            queryStr='select%20id%20from%20Account%20where%20name%3D%27Sales%27';
        }
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/query?query='+queryStr;
     
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
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object>  QueryResponse=(Map<String, Object>)m.get('QueryResponse');
            
            List<Object>  AccountList=(List<Object> )QueryResponse.get('Account');
            if(AccountList!=Null && !AccountList.isEmpty()){
                Map<String, Object> COGSMap=(Map<String, Object>)AccountList[0];
                QB_ID1=(String)COGSMap.get('Id'); 
                return QB_ID1;
            }else{
                QB_ID1=createCOGSAccount(CompanyId,AccountType);
                return QB_ID1;
            }
            
        }else{
            return Null;
        }
    }
    public static string createCOGSAccount(String CompanyId,string AccountType){
        String QB_ID1='';
        String str='';
        if(AccountType=='Cost Of Goods Sold'){
            str='{\"AccountType\": \"Cost of Goods Sold\","Name\": \"Cost of Goods Sold\"}';
        }else if(AccountType=='Sales'){
            str='{\"AccountType\": \"Income\","Name\": \"Sales\"}';
        }
        
        String endpoint = 'https://quickbooks.api.intuit.com/v3/company/'+CompanyId+'/account';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');   
        req.setBody(str);
        req = QuickbooksAPI.signRequest(req);
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept' , 'application/json');
            
        HttpResponse res;
        res = http.send(req); 
        String resParams = res.getBody();
        string outputString = res.getBody();
        if(res.getStatusCode()==200){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            Map<String, Object>  COGSMap=(Map<String, Object>)m.get('Account');
            QB_ID1=(String)COGSMap.get('Id'); 
        }else{
            QuickbooksUtility.ErrorClass errorObj=QuickbooksUtility.parseError(res.getBody());
            string ErrorToShow=errorObj.Fault.Error[0].Detail;
            return Null;
        }
        return QB_ID1;
    }
    public PageReference redirectToItem(){
        PageReference reference=new PageReference('/'+prodId);
        reference.setRedirect(true);
        return reference;
    }
    
    //Wrapper for Response parsing
    public class ItemJsonResponse{
        public cls_Item Item;
    }
    public class cls_Item{
        public String Name; //Office Supplies
        public String Description;  //This is the sales description.
        public boolean Active;
        public String FullyQualifiedName;   //Office Supplies
        public boolean Taxable;
        public Decimal UnitPrice;   //25
        public String Type; //Inventory
        public cls_IncomeAccountRef IncomeAccountRef;
        public String PurchaseDesc; //This is the purchasing description.
        public Decimal PurchaseCost;    //35
        public cls_ExpenseAccountRef ExpenseAccountRef;
        public cls_AssetAccountRef AssetAccountRef;
        public boolean TrackQtyOnHand;
        public Decimal QtyOnHand;   //10
        public Date InvStartDate;   //2013-02-19
        public String domain;   //QBO
        public boolean sparse;
        public boolean SubItem;
        public String Id;   //37
        public String SyncToken;    //0
        public cls_MetaData MetaData;
        public cls_ParentRef ParentRef;
    }
     public class cls_ParentRef {
        public String value;    //79
        public String name; //Sales of Product Income
    }
    public class cls_IncomeAccountRef {
        public String value;    //79
        public String name; //Sales of Product Income
    }
    public class cls_ExpenseAccountRef {
        public String value;    //80
        public String name; //Cost of Goods Sold
    }
    public class cls_AssetAccountRef {
        public String value;    //81
        public String name; //Inventory Asset
    }
    public class cls_MetaData {
        public DateTime CreateTime;   //2015-04-22T11:03:23-07:00
        public DateTime LastUpdatedTime;  //2015-04-22T11:03:24-07:00
    }
}
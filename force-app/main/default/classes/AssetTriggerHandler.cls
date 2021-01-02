/*------------------------------------------------------------
 * AssetTriggerHandler
 * @Author: Amit Saini
 * @Company: Sky Deustchland GmbH
 * @Description: Class to handle business logic of AssetTrigger 
 * Test Class: AssetTriggerClass_TEST

    History
    <Date>    <Version>      <Brief Description of Change>
    26.11.2020    1.0            Initial creation
    
------------------------------------------------------------*/
public without sharing class AssetTriggerHandler  extends TriggerHandler{

    /*****************************************************************
    Purpose: Constructor of the Handler Class.Initialize this handler, prevent infinite recursion.
    Parameters: None
    History
    --------
    VERSION         AUTHOR                     DATE            DETAIL  
    1.0            Amit S      276.11.2020        Created 
    *****************************************************************/
    public AssetTriggerHandler() {
        super();
        this.setMaxLoopCount(50);
    }
    
    /*****************************************************************
    Purpose: Runs in the Context of Before Insert and Before Update Assign the Base Price Value of assest
    Parameters: None
    History
    --------
    VERSION       AUTHOR       DATE           DETAIL  
    1.0           Amit S      26.11.2020     Created 
    *****************************************************************/   
    protected override void beforeInsert(){  
        assignBasePriceValue();        
    }
    
    protected override void beforeUpdate(){  
        assignBasePriceValue();        
    }   
   
    /*****************************************************************
    Purpose: Assign the Base Price Value of assest
    Parameters: None
    History
    --------
    VERSION       AUTHOR       DATE           DETAIL  
    1.0           Amit S      26.11.2020     Created 
    *****************************************************************/ 
    @TestVisible
    private void assignBasePriceValue(){
        List<Asset> newAssetList;
        newAssetList = (List<Asset>)Trigger.New;
        Map<Id,Asset> oldMap;
        oldMap = (Map<Id,Asset>)Trigger.oldMap; 
    
        try {
            for(Asset at: newAssetList) {
                if(String.isNotBlank(at.vlocity_cmt__PricingLogData__c)){
                    if(Trigger.IsInsert || (Trigger.IsUpdate && at.vlocity_cmt__PricingLogData__c != oldMap.get(at.Id).vlocity_cmt__PricingLogData__c)){
                        Map<String, Object> assetReqMap = (Map<String, Object>)JSON.deserializeUntyped(at.vlocity_cmt__PricingLogData__c);
                        if(assetReqMap.containskey(ServiceConstants.ASSET_PRICEBASEVAL) && assetReqMap.get(ServiceConstants.ASSET_PRICEBASEVAL) != null){ 
                            Map<String,Object> priceVarBaseValMap = (Map<String,Object>)assetReqMap.get(ServiceConstants.ASSET_PRICEBASEVAL);
                                                        
                            if(priceVarBaseValMap != null){
                                //Always retrieving the first element of priceVarBaseValMap 
                                at.Base_Price_Value__c = getBasePriceValue((Decimal)priceVarBaseValMap.get(new List<String> (priceVarBaseValMap.KeySet()).get(0)));  
                            } 
                        }
                    }
                } 
            }
        }catch(exception e){
            System.debug('--Ex--'+e.getStackTraceString());
            ApplicationLogUtility.logMessageSync('Debug','AssetTriggerHandler','assignBasePriceValue',e.getMessage(),null,e,null);                       
        }
    }
    
    /*****************************************************************
    Purpose: Convertion of base price from decimal to valid string format
    Parameters: Decimal
    History
    --------
    VERSION       AUTHOR       DATE           DETAIL  
    1.0           Amit S      26.11.2020     Created 
    *****************************************************************/    
    @TestVisible
    private static String getBasePriceValue(Decimal basePriceVal){
        String basePrice ='';
        if(basePriceVal != null){
            Decimal uptoTwoDecValOfBP = basePriceVal.setScale(2);
            String strBasePrice = uptoTwoDecValOfBP.toPlainString();
            strBasePrice = strBasePrice.substring(strBasePrice.indexOf('.')+1,strBasePrice.length());
            if(strBasePrice.equals('00')){
              basePrice = String.valueOf(Integer.ValueOf(uptoTwoDecValOfBP));  
            }else{
              basePrice = String.valueOf(uptoTwoDecValOfBP);  
            }
        }
        return basePrice;    
    }    

}
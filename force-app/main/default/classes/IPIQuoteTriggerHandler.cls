public with sharing class IPIQuoteTriggerHandler extends TriggerHandler {

    private void checkStock(List<IPI_Quote__c> quotes,Map<ID,IPI_Quote__c> oldQuotMap){
        
        map<id,decimal> quotsPerTrucs=new map<id,decimal>();
        for(IPI_Quote__c quo:quotes){
            if((oldQuotMap==null || (oldQuotMap.get(quo.id).IPI_Status__c!=quo.IPI_Status__c ||
               oldQuotMap.get(quo.id).IP_Quantity__c!=quo.IP_Quantity__c) )&& quo.IPI_Status__c=='reserved'){
                if(!quotsPerTrucs.containskey(quo.IPI_Truck__c))
                   quotsPerTrucs.put(quo.IPI_Truck__c,quo.IP_Quantity__c);
                 else 
                    quotsPerTrucs.put(quo.IPI_Truck__c, quotsPerTrucs.get(quo.IPI_Truck__c)+quo.IP_Quantity__c);
            }
        }    
        Map<id,Ipi_Truck__c> mapTruck=new map<id,Ipi_Truck__c>([select id,Ipi_StockQuantity__c,name from Ipi_Truck__c where id in:quotsPerTrucs.keyset()]);
        set<id>invalidTrucks= new set<id>();
        for(Id  idtr:quotsPerTrucs.keyset()){
           if(mapTruck.get(idtr).Ipi_StockQuantity__c >= quotsPerTrucs.get(idtr))
              mapTruck.get(idtr).Ipi_StockQuantity__c-=quotsPerTrucs.get(idtr);
            else
                invalidTrucks.add(idtr);
             
        }
        for(IPI_Quote__c quo:quotes){   
            if(invalidTrucks.contains(quo.IPI_Truck__c))
                quo.addError('insufficient stock for the truck '+mapTruck.get(quo.IPI_Truck__c).Name);
        }
        for(id idd:invalidTrucks)
            mapTruck.remove(idd);

        if(mapTruck.values().size()>0)
           update mapTruck.values();
    }
    private void checkContract(Map<ID,IPI_Quote__c> newRecordMap,Map<ID,IPI_Quote__c> oldQuotMap){
        set<id>recordsToCheck = new set<id>();
        for(id idd:newRecordMap.keyset()){
            IPI_Quote__c quo=newRecordMap.get(idd);
            if((oldQuotMap==null || (oldQuotMap.get(quo.id).IPI_Status__c!=quo.IPI_Status__c)) && quo.IPI_Status__c=='closed'){
                recordsToCheck.add(quo.id);
            }
        }
        if(recordsToCheck.size()>0){
            List<Contract> ctrts= new  List<Contract>();
            for(IPI_Quote__c quo:[select id,IPI_Client__r.name,	IPI_Truck__r.Ipi_Version__c,(select id from Contracts__r limit 1) from IPI_Quote__c where id in:recordsToCheck]){
              if(quo.Contracts__r.size()==0){

                integer qtdays;
                if(quo.IPI_Truck__r.Ipi_Version__c=='New'){
                   if(Date.isLeapYear(Date.today().year())){
                      qtdays=366;
                   }else
                      qtdays=365;
                }else{
                    qtdays=90;
                }
                
                Contract ctrl=new Contract();
                ctrl.name=quo.IPI_Client__r.name +' '+newRecordMap.get(quo.id).name;
                ctrl.AccountId=newRecordMap.get(quo.id).IPI_Client__c;
                ctrl.IPI_Quote__c=quo.id;
                ctrl.Status='Draft';
                ctrl.StartDate=Date.today();
                ctrl.ContractTerm=qtdays==90?3:12;
                ctrts.add(ctrl);
              }  
              if(ctrts.size()>0)
                 insert ctrts;
              
            }
        }
    
    }
    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){
        this.checkStock((List<IPI_Quote__c>)newRecords,null);  
    }
    public override void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){
        this.checkStock((List<IPI_Quote__c>) newRecords,(Map<ID,IPI_Quote__c>)oldRecordMap);
        this.checkContract((Map<ID,IPI_Quote__c>)newRecordMap,(Map<ID,IPI_Quote__c>)oldRecordMap) ;
    }
}
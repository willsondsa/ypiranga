public with sharing class IPIQuoteTriggerHandler extends TriggerHandler {

    private void checkStock(List<IPI_Quote__c> quotes,Map<ID,IPI_Quote__c> oldQuotMap){
        
        map<id,decimal> quotsPerTrucs=new map<id,decimal>();
        for(IPI_Quote__c quo:quotes){
            if((oldQuotMap==null || (oldQuotMap.get(quo.id).IP_Quantity__c!=quo.IP_Quantity__c) )&& ((quo.IPI_Status__c=='reserved'||quo.IPI_Status__c=='closed')&& quo.IPI_type__c!='Renewal')){
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
            if((oldQuotMap==null || (oldQuotMap.get(quo.id).IPI_Status__c!=quo.IPI_Status__c)) && (quo.IPI_Status__c=='closed' && quo.IPI_type__c!='Renewal')){
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
                ctrl.IPI_WarrantyDays__c=qtdays;
                ctrts.add(ctrl);
              }  
             
            }
            system.debug('teste '+JSON.serialize(ctrts));
            if(ctrts.size()>0)
               insert ctrts;
            
        }
    
    }
    private void checkWarranties(Map<ID,IPI_Quote__c> newRecordMap,Map<ID,IPI_Quote__c> oldQuotMap){
 
        set<string>recordsToCheck = new  set<string>();
        Map<string,IPI_Quote__c> wuotsPercode= new Map<string,IPI_Quote__c>();
        for(id idd:newRecordMap.keyset()){
            IPI_Quote__c quo=newRecordMap.get(idd);
            if((oldQuotMap==null || (oldQuotMap.get(quo.id).IPI_type__c!=quo.IPI_type__c)) && (quo.IPI_type__c=='Renewal')){
                recordsToCheck.add(quo.IPI_WarrantyCode__c);
                wuotsPercode.put(quo.IPI_WarrantyCode__c,quo);
            }
            
        }
        system.debug('nas data '+recordsToCheck);
        if(recordsToCheck.size()>0){
           List<Contract>ctrts= new List<Contract>();
           List<IPI_warranty__c> warranties=new List<IPI_warranty__c>();
           List<IPI_Quote__c> quotdpd=new List<IPI_Quote__c>();
           for(IPI_warranty__c wr:[select id,IPI_Contract__c,IPI_Contract__r.IPI_Quote__c,IPI_Warrantycode__c from IPI_warranty__c where IPI_Warrantycode__c in:recordsToCheck and IPI_Status__c='Not Insured']){
               IPI_Quote__c quo=wuotsPercode.get(wr.IPI_Warrantycode__c);
               quotdpd.add(new IPI_Quote__c(id=quo.id,IPI_InitialQuote__c=wr.IPI_Contract__r.IPI_Quote__c));
               ctrts.add(new Contract(id=wr.IPI_Contract__c, StartDate=Date.today(),IPI_WarrantyDays__c=quo.IPI_numberOfRenewalDays__c));
   
               warranties.add(new IPI_warranty__c(id=wr.id,  IPI_Duedate__c=Date.today().adddays((integer)quo.IPI_numberOfRenewalDays__c )));
               recordsToCheck.remove(wr.IPI_Warrantycode__c);
           }
           for(IPI_Quote__c quo:newRecordMap.values()){
              if(recordsToCheck.contains(quo.IPI_WarrantyCode__c))
                quo.addError('no warranty found for the code:'+quo.IPI_WarrantyCode__c);
           }
          
           if(ctrts.size()>0)
              update ctrts;
            if(warranties.size()>0)
               update warranties;
            if(quotdpd.size()>0)
               update quotdpd;
       }

    }
    
    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){
        this.checkStock((List<IPI_Quote__c>)newRecords,null);  
        this.checkContract((Map<ID,IPI_Quote__c>)newRecordMap,null) ;
        this.checkWarranties((Map<ID,IPI_Quote__c>)newRecordMap,null) ;
    }
    public override void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){
        this.checkStock((List<IPI_Quote__c>) newRecords,(Map<ID,IPI_Quote__c>)oldRecordMap);
        this.checkContract((Map<ID,IPI_Quote__c>)newRecordMap,(Map<ID,IPI_Quote__c>)oldRecordMap) ;
        //this.checkWarranties((Map<ID,IPI_Quote__c>)newRecordMap,(Map<ID,IPI_Quote__c>)oldRecordMap) ;
    }
}
public with sharing class ContractTriggerHAndler extends TriggerHandler  {
    public ContractTriggerHAndler() {

    }
    private void CreateWarranties(List<contract> newRecords){
      List<IPI_warranty__c> wrrs=new List<IPI_warranty__c>();
      for(Contract c:newRecords){
          
       }
    }
    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){

    }
}
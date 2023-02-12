public with sharing class ContractTriggerHAndler extends TriggerHandler  {
    public ContractTriggerHAndler() {

    }
    private void CreateWarranties(List<contract> newRecords){
      List<IPI_warranty__c> wrrs=new List<IPI_warranty__c>();
      for(Contract c:newRecords){
         if(c.ipi_Quote__c!=null){
            wrrs.add(new IPI_warranty__c(IPI_Contract__c=c.id,IPI_Duedate__c=c.StartDate.addDays((integer)c.IPI_WarrantyDays__c)));
         }
         if(wrrs.size()>0)
            insert wrrs;
      }
    }
    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){
      CreateWarranties((List<contract>) newRecords);
    }
}
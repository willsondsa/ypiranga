public class AccountTriggerHandler  extends TriggerHandler {
    
   public override void beforeInsert(List<SObject> newRecords){
       AccountHelper.checkcepRecords((List<Account>)newRecords,null);
   }
   public override void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){
        AccountHelper.checkcepRecords((List<Account>)newRecords,(Map<id,Account>)oldRecordMap);
   }
}
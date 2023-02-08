public abstract class TriggerHandler {
    
    
    public void start(){
         switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                this.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                // handler.beforeDelete(Trigger.old, Trigger.oldMap);
                this.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                // handler.afterInsert(Trigger.new, Trigger.newMap);
                this.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                this.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                this.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                this.afterUndelete(Trigger.new, Trigger.newMap);
            }
         }
    }
    public virtual void beforeInsert(List<SObject> newRecords){}
    public virtual void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){}
    public virtual void beforeDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap){}
    public virtual void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){}
    public virtual void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){}
    public virtual void afterDelete(List<SObject> oldRecords, Map<ID, SObject> oldRecordMap){}
    public virtual void afterUndelete(List<SObject> newRecords, Map<ID, SObject> newRecordMap){}
}
public with sharing class IPI_ContactTriggerHandler extends TriggerHandler {
    
    public void CreateAcccountsForSimpleContacts(List<Contact> acc){
        Id recordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Simple_Customer').getRecordTypeId();
        map<id,Account> ccs= new map<id,Account>();
        for(contact c: acc){
            if(c.recordTypeId==recordTypeId && c.Accountid==null)
              ccs.put(c.id,new Account(Name=c.firstname+' '+c.Lastname));
        }
        if(ccs.values().size()>0){
            List<contact> contactsToUpdate = new List<contact>();
            System.debug('value to insert '+JSON.serialize(ccs.values()));
            insert ccs.values();
            for(id idd:ccs.keyset()){
                contactsToUpdate.add(new contact(id=idd,Accountid=ccs.get(idd).id));
            }
            update contactsToUpdate;
        }

    }
    public override void afterInsert(List<SObject> newRecords, Map<ID, SObject> newRecordMap){
        this.CreateAcccountsForSimpleContacts((List<Contact>)newRecords);
    }
}
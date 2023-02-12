trigger IPIQuoteTrigger on IPI_Quote__c (after insert,after update) {
 new IPIQuoteTriggerHandler().start();
}
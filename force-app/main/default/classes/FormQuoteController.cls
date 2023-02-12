public with sharing class FormQuoteController {
    public FormQuoteController() {

    }

    @AuraEnabled
    public static List<IPI_Quote__c> SaveRecords(List<IPI_Quote__c> quotes){
        insert quotes;
        return quotes;
    }
}
trigger IPI_ContactTrigger on Contact (after insert) {
  new IPI_ContactTriggerHandler().start();
}
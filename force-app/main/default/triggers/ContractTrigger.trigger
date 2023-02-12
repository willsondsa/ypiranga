trigger ContractTrigger on contract (after insert) {
  new ContractTriggerHAndler().start();
} 
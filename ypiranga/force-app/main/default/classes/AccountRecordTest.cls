@istest
public class AccountRecordTest {
    @istest
    static void testValidCep(){
        List<Account>accs= new List<Account>();
        Account ac1= new Account(name='test1Ac',BillingPostalCode='60711735');
        accs.add(ac1);
        Account ac2= new Account(name='test1Ac2',BillingPostalCode='60735');
        accs.add(ac2);
        integer countError=0;
        for (Database.SaveResult sr :DataBase.insert(accs,false)) {
             if (!sr.isSuccess()) {         
               for(Database.Error err : sr.getErrors()) {
                   system.assert(err.getMessage().contains(ac2.BillingPostalCode));
                   countError++;
                 
               }
            }
       }
        system.assertEquals(countError,1);
        accs=[select id,BillingPostalCode from account where BillingPostalCode='60711735'and name='test1Ac' ];
        system.assertEquals(accs.size(),1);  
        accs[0].BillingPostalCode='fdfsfsfs';
        for (Database.SaveResult sr :DataBase.update(accs,false)) {
             if (!sr.isSuccess()) {         
               for(Database.Error err : sr.getErrors()) 
                   system.assert(err.getMessage().contains(accs[0].BillingPostalCode));
            }
       }
        
    }

}
public class AccountHelper {
    public static boolean ValidCep(string cep){
       Pattern p = Pattern.compile('^(\\d{5}(\\-\\d{3})?)?$');
       Pattern p2=Pattern.compile('^(\\d{5}(\\d{3})?)?$');
      Matcher pm= p.matcher(cep);
        Matcher pm2= p2.matcher(cep);
       return (pm.matches()||pm2.matches())&& cep.length()>5;
    }
    public static void checkcepRecords(List<account>newAccounts,map<id,Account>oldAccounts){
        for(Account c:newAccounts){
            if(((oldAccounts!=null && oldAccounts.get(c.id).BillingPostalCode!=c.BillingPostalCode) ||(oldAccounts==null)) && !ValidCep(c.BillingPostalCode))
               c.addError(' Cep Invalido :'+c.BillingPostalCode);
            
        }
    }
}
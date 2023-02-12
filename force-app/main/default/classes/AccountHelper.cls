public class AccountHelper {
    public static boolean ValidCep(string cep){
       Pattern p = Pattern.compile('^(\\d{5}(\\-\\d{3})?)?$');
      Matcher pm= p.matcher(cep);
       return pm.matches()&& cep.length()>5;
    }
    public static void checkcepRecords(List<account>newAccounts,map<id,Account>oldAccounts){
        for(Account c:newAccounts){
            if(!string.isempty(c.BillingPostalCode)){
            if(!c.BillingPostalCode.contains('-'))
                c.BillingPostalCode=c.BillingPostalCode.substring(0,5)+'-'+c.BillingPostalCode.substring(5,c.BillingPostalCode.length());
            if(((oldAccounts!=null && oldAccounts.get(c.id).BillingPostalCode!=c.BillingPostalCode) ||(oldAccounts==null)) && !ValidCep(c.BillingPostalCode))
               c.addError(' Cep Invalido :'+c.BillingPostalCode);
            }
            
        }
    }
}
public class QuestionQ2 {
     Public static void BloqueiaIntegracao1(List<Opportunity> Opp){
    set<Id>oppids=new set<id>();
    for(Opportunity OppA : Opp)
        oppids.add(OppA.id);
    set<id>validOpps=new set<id>();

    for(OpportunityContactRole oprl:[SELECT id,Opportunityid from OpportunityContactRole where             Opportunityid in :oppids AND Role =: 'Responsável Financeiro'])
        validOpps.add(oprl.Opportunityid);

    for(Opportunity OppA : Opp){
      if(!validOpps.contains(OppA.id))
         oppA.addError( 'É necessario ter o papel financeiro alinhado na oportunidade.');
      
    }

}


Public static void BloqueiaIntegracao2(List<Opportunity> Opp){
    set<Id>oppids=new set<id>();
    for(Opportunity OppA : Opp)
        oppids.add(OppA.id);

    for(Opportunity op:[SELECT id,(select id from OpportunityContactRoles where Role = 'Responsável Financeiro' limit 1)
	             Opportunityid from Opportunity  where id in:oppids]){
		if(op.OpportunityContactRoles.size()==0)
		  op.addError( 'É necessario ter o papel financeiro alinhado na oportunidade.');
					 
    }
     
}

}
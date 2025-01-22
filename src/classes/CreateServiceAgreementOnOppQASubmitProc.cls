//SECURED!
public with sharing class CreateServiceAgreementOnOppQASubmitProc extends AbstractProcessor  {

    public override Response process(Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        maica_cc__Service_Agreement__c serviceAgreementVar = new maica_cc__Service_Agreement__c();
        this.request.getMapper().mapToSObject('serviceAgreement', serviceAgreementVar);
        DMLManager.insertAsUser(serviceAgreementVar);

        List<maica_cc__Agreement_Item__c> agreementItems = this.request.getMapper().mapToListSObjects('agreementItems', maica_cc__Agreement_Item__c.SObjectType);
        for(maica_cc__Agreement_Item__c agreementItem : agreementItems){
            agreementItem.maica_cc__Service_Agreement__c = serviceAgreementVar.Id;
            agreementItem.maica_cc__Start_Date__c = serviceAgreementVar.maica_cc__Start_Date__c;
            agreementItem.maica_cc__End_Date__c = serviceAgreementVar.maica_cc__End_Date__c;
            agreementItem.maica_cc__Funding_Type__c = serviceAgreementVar.maica_cc__Funding_Type__c;
        }
        DMLManager.insertAsUser(agreementItems);

        this.response.put('serviceAgreement', serviceAgreementVar);
    }

}
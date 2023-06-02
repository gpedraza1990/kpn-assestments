@isTest
public class KPNTestDataFactory {

    public static Account createAccount() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;
        return account;
    }

    public static Contract createContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Status = 'Draft',
            ContractTerm = 1,
            StartDate = System.today() -1
        );
        insert contract;
        return contract;
    }

    

    public static Order createOrder(Id accountId, Id contractId, Id pricebookId) {
        Order order = new Order(
            Status = 'Draft',
            EffectiveDate = System.today()-1,
            ContractId = contractId,
            AccountId = accountId,
            Pricebook2Id = pricebookId
        );
        insert order;
        return order;
    }
}
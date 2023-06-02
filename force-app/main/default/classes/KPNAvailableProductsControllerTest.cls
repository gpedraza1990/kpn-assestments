/**
* Class Name: KPNAvailableProductsControllerTest 
* Author: Gabriel Pedraza
* Date: Dec, 2021
* Description: Test class for KPNAvailableProductsController
* Project: Demo
**/
@isTest(SeeAllData=true)
private class KPNAvailableProductsControllerTest {

    // We should not use annotation @isTest(SeeAllData=true)
    // Due to the time available we use the annotation approach
    // best practice is use setup and create all data from scratch
	// @testSetup
    // private static void setup(){
	// 	Id priceBookId = [SELECT id, name from Pricebook2 where name = 'Standard' Limit 1].Id;
    //     Id accountId = KPNTestDataFactory.createAccount().Id;
    //     // Create test data
    //     Id orderId = KPNTestDataFactory.createOrder(accountId,
	// 											KPNTestDataFactory.createContract(accountId).Id,
	// 											priceBookId).Id;
	// }

    @isTest
    static void testGetAvailableProducts() {

		Id orderId = testSetUp();
        Test.startTest();
			// Call the method to test
			List<KPNAvailableProductsController.ProductWrapper> result = KPNAvailableProductsController.getAvailableProducts(orderId, 10, 0);
        Test.stopTest();
        // Perform assertions
        System.assertEquals(10, result.size(), 'Incorrect number of available products');
        
    }
    
    @isTest
    static void testaddOrderProduct() {

        Id orderId = testSetUp();
        Id productId = [Select id from Product2 Limit 1].Id;

        // Call the method to test
        Test.startTest();
        	KPNAvailableProductsController.addOrderProduct(orderId, productId);
			List<OrderItem> result = [Select id from OrderItem where OrderId = :orderId];
        Test.stopTest();
        
        // Perform assertions or query OrderItem records to validate the expected changes
        System.assertEquals(1, result.size(), 'Incorrect ordered products');
    }

    @isTest
    static void testgetOrderProducts() {

        Id orderId = testSetUp();
        Id productId = [Select id from Product2 Limit 1].Id;
        // Call the method to test
        Test.startTest();
            KPNAvailableProductsController.addOrderProduct(orderId, productId);
            List<KPNOrderProductsController.OrderProductWrapper> result = KPNOrderProductsController.getOrderProducts(orderId);
        Test.stopTest();

        // Perform assertions or query OrderItem records to validate the expected changes
        System.assertEquals(1, result.size(), 'Incorrect number ordered products');

    }

    @isTest
    static void testactivateOrder() {

        Id orderId = testSetUp();
        Id productId = [Select id from Product2 Limit 1].Id;

        Id contractId = [Select ContractId FROM Order where id =: orderId Limit 1].ContractId;
        Contract updateContract = [select Status from Contract where id = : contractId Limit 1];
        
        // Call the method to test
        Test.startTest();
            // An order must have at least one product
            KPNAvailableProductsController.addOrderProduct(orderId, productId);
            // An order must have an active contract
            updateContract.Status = 'Activated';
            update updateContract;
            //Activate de order
            KPNOrderProductsController.activateOrder(orderId);
            String status = [Select Status from Order where id = : orderId Limit 1].Status;
        Test.stopTest();

        // Perform assertions or query OrderItem records to validate the expected changes
        System.assertEquals('Activated', status, 'Incorrect status');

    }


    private static Id testSetUp(){
         // Create test data
		Id priceBookId = [SELECT id, name from Pricebook2 where name = 'Standard' Limit 1].Id;
        Id accountId = KPNTestDataFactory.createAccount().Id;
       
        Id orderId = KPNTestDataFactory.createOrder(accountId,
												KPNTestDataFactory.createContract(accountId).Id,
												priceBookId).Id;
        Id productId = [Select id from Product2 Limit 1].Id;

        return orderId;

    }


    
}
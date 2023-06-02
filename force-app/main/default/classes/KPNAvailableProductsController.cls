/**
* Class Name: KPNAvailableProductsController 
* Author: Gabriel Pedraza
* Date: Dec, 2021
* Description: a class that have the logic for available lwc
* Project: Demo
**/
public with sharing class KPNAvailableProductsController {

    /**
     * getAvailableProducts
     * @description get available products from an order with pagination
     * @return List<ProductWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getAvailableProducts(Id orderId, Integer limitSize, Integer offset) {
        // Fetch the Order's price book ID
        Id pricebookId = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId].Pricebook2Id;
        
        // Fetch the order items on the current order
        List<OrderItem> orderItems = [SELECT Product2Id FROM OrderItem WHERE OrderId = :orderId];
        
        // Extract the Product IDs from the order items
        Set<Id> productIds = new Set<Id>();
        for (OrderItem item : orderItems) {
            productIds.add(item.Product2Id);
        }
        
        // Query for the available products based on the price book and filtering criteria

        List<PricebookEntry> availableProducts = [
            SELECT Id, Product2Id, Product2.Name, ProductCode, UnitPrice 
            FROM PricebookEntry 
            WHERE  Pricebook2Id =: pricebookId
            ORDER BY Name ASC
            LIMIT :limitSize
            OFFSET :offset
        ];
        
        // Create a list of ProductWrapper instances
        List<ProductWrapper> productWrappers = new List<ProductWrapper>();
        for (PricebookEntry priceBook : availableProducts) {
            productWrappers.add(new ProductWrapper(priceBook.Product2Id, 
            priceBook.Product2.Name, 
            priceBook.UnitPrice, 
            priceBook.ProductCode, 
            productIds.contains(priceBook.Product2Id)));
        }
        
        return productWrappers;
    }

    /**
     * addOrderProduct
     * @description Add a product to OrderItem or update the quantity if it is
     * already there
     * @return 
     */
    @AuraEnabled
    public static void addOrderProduct(Id orderId, Id productId) {

        if(validateOrder(orderId)){
            // Fetch the Order's price book ID
            Id pricebookId = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId].Pricebook2Id;

            PricebookEntry priceBookEntry = [SELECT Id,  UnitPrice FROM PricebookEntry 
                                            WHERE Product2Id = :productId and Pricebook2Id =: pricebookId LIMIT 1];

            // Check if exist OrderItem
            List<OrderItem> orderItems = [SELECT Id,Product2Id, Quantity FROM OrderItem WHERE OrderId = :orderId and Product2Id = :productId Limit 1];
            
            try {

                if(orderItems.size() > 0){
                    orderItems[0].Quantity +=1;
                }
                else{
                    OrderItem orderItem = new OrderItem(
                        OrderId = orderId,
                        Product2Id = productId,
                        Quantity = 1,
                        PricebookEntryId = priceBookEntry.Id,
                        UnitPrice = priceBookEntry.UnitPrice
                    );
                    orderItems.add(orderItem);
                }
                
                upsert orderItems;
                
            } catch (Exception ex) {
                // Handle exception
                System.debug('Error adding product to order: ' + ex.getMessage());
            }
        }

        
    }

     /**
     * validateOrder
     * @description Check if an order is activated
     * @return boolean
     */

    private static boolean validateOrder(Id orderId){
        Order orderRecord = [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];

        return orderRecord.Status != 'Activated';
    }

    /**
     * ProductWrapper
     * @description Class to wrap list of products
     */

    public class ProductWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal productListPrice;
        @AuraEnabled public String productCode;
        @AuraEnabled public Boolean productIsOrdered;

        
        /**
         * ProductWrapper
         * @description Constructor
         */
        public ProductWrapper(Id id, String name, Decimal listPrice, String code, Boolean isOrdered) {
            productId = id;
            productName = name;
            productListPrice = listPrice;
            productCode = code;
            productIsOrdered = isOrdered;
        }
    }
}
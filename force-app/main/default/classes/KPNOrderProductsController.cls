/**
* Class Name: KPNOrderProductsController 
* Author: Gabriel Pedraza
* Description: a class that have the logic for order product lwc
* Project: Demo
**/
public with sharing class KPNOrderProductsController {

    /**
     * getOrderProducts
     * @description get ordered products from an order
     * @return List<OrderProductWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static List<OrderProductWrapper> getOrderProducts(Id orderId) {
        List<OrderProductWrapper> orderProducts = new List<OrderProductWrapper>();

        try {
            List<OrderItem> orderItems = [SELECT Id, Product2.Name, UnitPrice, Quantity, TotalPrice
                                          FROM OrderItem
                                          WHERE OrderId = :orderId];
            for (OrderItem item : orderItems) {
                OrderProductWrapper wrapper = new OrderProductWrapper(
                    item.Id,
                    item.Product2.Name,
                    item.UnitPrice,
                    item.Quantity,
                    item.TotalPrice
                );
                orderProducts.add(wrapper);
            }
        } catch (Exception ex) {
            // Handle exception
            System.debug('Error retrieving order products: ' + ex.getMessage());
        }

        return orderProducts;
    }

    /**
     * activateOrder
     * @description Activate an order
     * @return 
     */

    @AuraEnabled
    public static void activateOrder(Id orderId) {
        Order orderRecord = [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
        
        // Update order status to "Activated"
        orderRecord.Status = 'Activated';
        
        // Perform DML to save the changes
        update orderRecord;
    }

    /**
     * OrderProductWrapper
     * @description Class to wrap list of ordered products
     */
    public class OrderProductWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public String productName;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal totalPrice;

        /**
         * OrderProductWrapper
         * @description Constructor
         */
        public OrderProductWrapper(Id productId, String productName, Decimal unitPrice, Decimal quantity, Decimal totalPrice) {
            this.productId = productId;
            this.productName = productName;
            this.unitPrice = unitPrice;
            this.quantity = quantity;
            this.totalPrice = totalPrice;
        }
    }
}
import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/KPNOrderProductsController.getOrderProducts';
import activateOrder from '@salesforce/apex/KPNOrderProductsController.activateOrder';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/MyMessageChannel__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import STATUS_FIELD from '@salesforce/schema/Order.Status';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class KPN_OrderProducts extends LightningElement {
    @api recordId;
    @track orderProducts = [];
    subscription;
    @wire(MessageContext)
    messageContext;

    isDisabled = false;
    _wireData;
    _wireOrderData;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    orderRecord(wireResult) {
        const { data, error } = wireResult;
        this._wireOrderData = wireResult;
        if (data) {
            this.isDisabled = data.fields.Status.value === 'Activated';
        } else if (error) {
            // Handle error
            console.error('Error retrieving order products:', error);
            this.isDisabled = false;
        }
    }


    columns = [
        { label: 'Product Name', fieldName: 'productName', type: 'text' },
        { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency', typeAttributes: { currencyCode: 'USD' } },
        { label: 'Quantity', fieldName: 'quantity', type: 'number' },
        { label: 'Total Price', fieldName: 'totalPrice', type: 'currency', typeAttributes: { currencyCode: 'USD' } }
    ];

    connectedCallback() {
        this.subscribeToOrderProductAdded();
    }
    
    @wire(getOrderProducts, { orderId: '$recordId' })
    wiredOrderProducts(wireResult) {
        const { data, error } = wireResult;
        this._wireData = wireResult;
        if (data) {
            this.orderProducts = data;
        } else if (error) {
            // Handle error
            console.error('Error retrieving order products:', error);
        }
    }

    subscribeToOrderProductAdded() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                SAMPLEMC,
                (message) => this.handleOrderProductAdded(message)
            );
        }
    }

    handleActivate(event){
        event.stopPropagation();

        if (this.isDisabled) {
            this.showToast('Error', 'Order is already activated.', 'error');
            return;
          }
          this.isDisabled = true;
        // Call the Apex method to activate the order
        activateOrder({ orderId: this.recordId })
            .then(result => {
                // Handle the success response
                // For example, show a success message or perform additional actions
                console.log('Order activated successfully');
                return this.handleRefresh();
            })
            .catch(error => {

                this.isDisabled = false;
                // Handle the error response
                // For example, show an error message or perform error handling
                const errorMessage =
                error?.body?.pageErrors?.[0]?.message || 'Failed to activate the order.';
            
                // Show the error message
                this.showToast('Error', errorMessage, 'error');
                console.error('Error updating order', error);
            });
         
    }

    handleOrderProductAdded(message) {
      return this.handleRefresh();
    }

    handleRefresh() {
        refreshApex(this._wireData);
        return refreshApex(this._wireOrderData);
    }

    disconnectedCallback() {
        this.unsubscribeFromOrderProductAdded();
    }

    unsubscribeFromOrderProductAdded() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
        });
        this.dispatchEvent(toastEvent);
      }
}
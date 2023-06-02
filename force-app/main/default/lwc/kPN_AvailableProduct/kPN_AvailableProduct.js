import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAvailableProducts from '@salesforce/apex/KPNAvailableProductsController.getAvailableProducts';
import addOrderProduct from '@salesforce/apex/KPNAvailableProductsController.addOrderProduct';
import { publish, MessageContext } from 'lightning/messageService';
import SAMPLEMC from "@salesforce/messageChannel/MyMessageChannel__c";

const actions = [
    { label: 'Add to Order', name: 'add' },
];
const COLUMNS = [
    { label: 'Product Name', fieldName: 'productName', type: 'text' },
    { label: 'List Price', fieldName: 'productListPrice', type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    {
        fieldName: 'productId',
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];



export default class KPN_AvailableProduct extends LightningElement {
    @track availableProducts = [];
    @track enable_infinite_loading = true;
    @track displayedProducts = [];
    // pagination properties
    rowLimit =20;
    rowOffSet=0;

    @wire(MessageContext)
    messageContext;

    @api recordId; // Provide a public API property to receive the recordId

    @wire(getRecord, { recordId: '$recordId', fields: ['Order.Id'] })
    order;
    get orderId() {
        return this.order.data ? this.order.data.fields.Id.value : null;
    }

    connectedCallback() {
        this.loadData();
    }
    
    //Order products by productIsOrdered Attribute (order products first)
    sortByisOrdered(products){
        return products.sort((a, b) => Number(b.productIsOrdered) - Number(a.productIsOrdered));
    }


    loadData(){
        return  getAvailableProducts({ orderId: this.recordId,limitSize: this.rowLimit , offset : this.rowOffSet })
        .then(result => {
            let updatedRecords;
             if(result.length !=0){
                updatedRecords = [...this.displayedProducts, ...result];
                this.displayedProducts = this.sortByisOrdered(updatedRecords);
             }
             else{
                this.enable_infinite_loading=false;
             }
           
        })
        .catch(error => {
            //Handle error
            console.error('Error adding product to order', error);
            this.displayedProducts = undefined;
        });
    }

    loadMoreData(event) {
        event.preventDefault();
        event.stopPropagation();
        const currentRecord = this.displayedProducts;
        const { target } = event;
        target.isLoading = true;

        this.rowOffSet = this.rowOffSet + this.rowLimit;
        this.loadData()
            .then(()=> {
                target.isLoading = false;
            });   
    }

    get columns() {
        return COLUMNS;
    }


    handleRowAction(event) {
        const productId = event.detail.row.productId;

        addOrderProduct({ orderId: this.recordId, productId: productId })
            .then(() => {
                const message = {
                    messageToSend: this.myMessage,
                    sourceSystem: "From LWC"
                };
                publish(this.messageContext, SAMPLEMC, message);
            })
            .catch(error => {
                //Handle error
                console.error('Error adding product to order', error);
            });
    }

}
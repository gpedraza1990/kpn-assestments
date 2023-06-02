# Project Name

This is a Salesforce project that includes a Lightning Web Component and an Apex controller for managing available products and order processing.

## Table of Contents

- [Project Description](#project-description)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Project Description

The project consists of a Lightning Web Component (LWC) called KPN_AvailableProduct, which displays a list of available products and allows adding them to an order. The LWC communicates with an Apex controller called KPNAvailableProductsController to retrieve available products and handle the adding of products to an order.
Additionally, the project includes a Lightning Web Component called KPNOrderedProduct, which displays a list of ordered products on the order record page. This component receives notifications from the KPN_AvailableProduct component when a product is added to the order.
The project also includes a test class to ensure the functionality of the LWC and Apex controller (KPNAvailableProductsControllerTest).

## Installation

To use this project, follow these steps:

1. Clone the repository to your local machine.
2. Deploy the Salesforce project using Salesforce DX or the Salesforce CLI.
3. Assign the necessary permissions to the user accessing the component and Apex controller.
4. Run the provided tests to ensure the functionality is working as expected.

## Usage

After installation, follow these steps to use the project:

1. Create a contract record.
4. Create an order record the two lwc should be visibles.
5. Click on the "Add to Order" button to add a product to the order.
6. The component will send a notification to the "OrderProduct" component, which will update the list of ordered products.


## License

[MIT License](LICENSE)
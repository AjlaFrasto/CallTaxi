# CallTaxi- Flutter application for a Taxi Service

## Desktop Application

### Admin
- **Username:** admin
- **Password:** test

## Mobile Application

### Driver
- **Username:** driver
- **Password:** test

### Regular User-Client
- **Username:** user
- **Password:** test

## RabbitMQ Test E-mail Adresses

### An email is sent after a vehicle is created or modified by a driver to the system administrator to notify them that the registration needs to be approved or rejected.

### Sender E-mail Adress
- **Email:** calltaxi.sender@gmail.com
- **Password:** calltaxitest

### Receiver E-mail Adress
- **Email:** calltaxi.receiver@gmail.com
- **Password:** calltaxitest

## Recommender System

### Recommender System uses Content-Based Filtering, it suggests vehicle tier for the drive you are about to request based on a previous drives of the user and also time of the day, and day of the week.

## Stripe Payment System

### Stipe Test Card
- **Card Number:** 4242 4242 4242 4242
- **Rest of the data:** Can be done arbitrarily

## 4 .env Files
- **Root the of project:** For sql and rabbitmq configuration
- **Root of the desktop-admin app:** For OpenRouteService api key 
- **Root of the mobile-driver app:** For OpenRouteService api key 
- **Root of the mobile-client app:** For OpenRouteService api key and Stripe keys
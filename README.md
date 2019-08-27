# Spreedly Airlines Sample App

Setup:

* Create the config/spreedly.yml file, copy the contents of config/spreedly.yml.sample over, & replace <environment_key>, <access_secret>, <gateway_token>, and <receiver_token> with your own actual values:

  * https://docs.spreedly.com/basics/credentials/

  * https://docs.spreedly.com/basics/gateway/

  * https://docs.spreedly.com/guides/payment-method-distribution/single-card/

Requirements:

* Runs locally (doesn't have to be deployed to Heroku or other)

* Does not have to use a database for persistence - can just be an ephemeral workflow or store what little state there might be in a user-specific cookie. You can use your local PG instance or sqlite, though, if you find that to be easiest.

As far as user-facing functionality goes it should:

* List a few "Spreedly Airlines" flights with associated prices

* Let a user (no need for login functionality, just let anybody do this)

  - Purchase a flight with a test credit card against the Spreedly test gateway
  
  - Purchase a flight using PMD that sends the card info to a travel partner like Expedia (using the echo endpoint to mimic an Expedia API call - the request/response format is immaterial). 

* If the credit card is expired or invalid in any way, display an error message back to the user

* Give the user the option to save their credit card for future payments

* List all processed transactions (can list all transactions across users, not user-specific)


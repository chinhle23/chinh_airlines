module TransactionsHelper
  require 'net/http'
  require 'json'

  def retrieve_transaction_token(uri, payment_token, amount, retain)
    transaction_request = transaction_post_request(uri, payment_token, amount, retain)

    transaction_response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(transaction_request).body
    end

    parsed_transaction_response = JSON.parse(transaction_response)
    parsed_transaction_response['transaction']['token']
  end

  def transaction_post_request(transaction_uri, payment_token, amount, retain)
    request = Net::HTTP::Post.new(transaction_uri)

    request.basic_auth(
      Rails.configuration.spreedly['environment_key'],
      Rails.configuration.spreedly['access_secret']
    )

    request['Content-Type'] = 'application/json'
    
    if transaction_uri.to_s.include? 'purchase.json'
      request.body = purchase_data(payment_token, amount, retain).to_json
    else
      request.body = pmd_data(payment_token).to_json
    end

    request
  end

  def purchase_data(payment_token, amount, retain)
    {
      'transaction' => {
        'payment_method_token' => payment_token,
        'amount' => amount,
        'currency_code' => 'USD',
        'retain_on_success' => retain
      }
    }
  end

  def pmd_data(payment_token)
    {
      'delivery' => {
        'payment_method_token' => payment_token,
        'url' => 'https://spreedly-echo.herokuapp.com',
        'headers' => 'Content-Type: application/json',
        'body' => '{ \"product_id\": \"916598\", \"card_number\": \"{{credit_card_number}}\" }'
      }
    }
  end

  def purchase_uri
    # build the cURL command mentioned here: https://docs.spreedly.com/basics/purchase/
    URI("https://core.spreedly.com/v1/gateways/#{Rails.configuration.spreedly['gateway_token']}/purchase.json")
  end
 
  def pmd_uri
    # build the cURL command mentioned here: 
    # https://docs.spreedly.com/guides/payment-method-distribution/single-card/#deliver-payment-method
    URI("https://core.spreedly.com/v1/receivers/#{Rails.configuration.spreedly['receiver_token']}/deliver.json")
  end 
end

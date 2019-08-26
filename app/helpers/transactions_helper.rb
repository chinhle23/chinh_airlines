module TransactionsHelper
  require 'net/http'
  require 'json'

  def retrieve_transaction_token(uri, payment_token, amount, retain)
    transaction_request = transaction_post_request(uri, payment_token, amount, retain)
    purchase_response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(transaction_request).body
    end

    parsed_purchase_response = JSON.parse(purchase_response)
    parsed_purchase_response['transaction']['token']
  end

  def transaction_post_request(transaction_uri, payment_token, amount, retain)
    request = Net::HTTP::Post.new(transaction_uri)

    request.basic_auth(
      Rails.configuration.spreedly['environment_key'],
      Rails.configuration.spreedly['access_secret']
    )

    request['Content-Type'] = 'application/json'
    request.body = purchase_data(payment_token, amount, retain).to_json
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

  def purchase_uri
    # build the cURL command mentioned here: https://docs.spreedly.com/basics/purchase/
    URI("https://core.spreedly.com/v1/gateways/#{Rails.configuration.spreedly['gateway_token']}/purchase.json")
  end
end

class TransactionsController < ApplicationController
  include TransactionsHelper

  def index
    @transactions = Transaction.all
  end

  def new
    @flight = Flight.find(params[:flight_id])
    @transaction = Transaction.new
    @transaction.flight_id = @flight.id
    @environment_key = Rails.configuration.spreedly['environment_key']
    @total_price = @flight.price
    @total_price += 200 if params[:hotel] == 'true'

    if params[:payment_method_token]
      payment_token = params[:payment_method_token]
      total_charge = params[:total_charge].to_i * 100
      retain = params[:save_card]
      transaction_token = retrieve_transaction_token(purchase_uri, payment_token, total_charge, retain)

      @transaction.transaction_token = transaction_token
      @transaction.total_charge = @flight.price
      @transaction.save
      flash.notice = "Transaction #{transaction_token} Completed!"

      if total_charge != @flight.price
        pmd_delivery_uri = URI("https://core.spreedly.com/v1/receivers/#{Rails.configuration.spreedly['receiver_token']}/deliver.json")
        pmd_delivery_post_request = Net::HTTP::Post.new(pmd_delivery_uri)

        pmd_delivery_post_request.basic_auth(
          Rails.configuration.spreedly['environment_key'],
          Rails.configuration.spreedly['access_secret']
        )

        pmd_delivery_post_request['Content-Type'] = 'application/json'
        pmd_delivery_post_request.body = {
          'delivery' => {
            'payment_method_token' => payment_token,
            'url' => 'https://spreedly-echo.herokuapp.com',
            'headers' => 'Content-Type: application/json',
            'body' => '{ \"product_id\": \"916598\", \"card_number\": \"{{credit_card_number}}\" }'
          }
        }.to_json

        pmd_delivery_response = Net::HTTP.start(pmd_delivery_uri.hostname, pmd_delivery_uri.port, use_ssl: true) do |http|
          http.request(pmd_delivery_post_request).body
        end
        parsed_pmd_delivery_response = JSON.parse(pmd_delivery_response)
        pmd_transaction_token = parsed_pmd_delivery_response['transaction']['token']
      end 
    end
  
    # redirect_to flight_transaction_path(@flight, @transaction)
  end  
end

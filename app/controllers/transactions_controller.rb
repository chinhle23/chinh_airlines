class TransactionsController < ApplicationController
  include TransactionsHelper

  def index
    @transactions = Transaction.all
    # https://ruby-doc.org/stdlib-2.6.3/libdoc/net/http/rdoc/Net/HTTP.html
    transactions_uri = URI('https://core.spreedly.com/v1/transactions.json?count=100&order=desc')
    transactions_get_request = Net::HTTP::Get.new(transactions_uri)

    transactions_get_request.basic_auth(
      Rails.configuration.spreedly['environment_key'],
      Rails.configuration.spreedly['access_secret']
    )

    transactions_get_request['Content-Type'] = 'application/json'

    transactions_response = Net::HTTP.start(transactions_uri.hostname, transactions_uri.port, use_ssl: true) do |http|
      http.request(transactions_get_request).body
    end
    parsed_transactions_response = JSON.parse(transactions_response)
    @results = parsed_transactions_response['transactions']
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
      purchase_transaction_token = retrieve_transaction_token(purchase_uri, payment_token, total_charge, retain)

      @transaction.transaction_token = purchase_transaction_token
      @transaction.total_charge = @flight.price
      @transaction.save
      flash.notice = "Transaction #{purchase_transaction_token} Completed!"

      if total_charge != @flight.price * 100
        pmd_transaction_token = retrieve_transaction_token(pmd_uri, payment_token, 0, retain)
        flash.notice = "PMD transaction #{pmd_transaction_token} Completed!"
      end 

      redirect_to flight_transactions_path(1)
    end
  end
end

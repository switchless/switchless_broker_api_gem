require "switchless_broker_api/version"
require "switchless_broker_api/stub"

module Broker
  BrokerError = Class.new(StandardError)

=begin
  # use something like this to initialize broker instance
  # Return the default Broker instance.
  def Broker.get(settings={})
    unless Rails.env.production?
      @@instance ||= Broker::StubbedApi.new #TODO use Faraday stubs.
      return @@instance
    end

    @@instance ||= Broker::Api.new(
      settings[:host],
      settings[:port],
      settings[:username],
      settings[:password],
      settings[:cert])
    @@instance
  end
=end
  
  include Stub


  class Api
    # Broker API interface

    def initialize(host, port, username, password, cert, logger=nil)
      @host = host
      @port = port
      @username = username
      @password = password
      @cert = cert
      @logger = logger || Logger.new("#{Rails.root}/log/broker.log")
    end

    QUOTE_TYPE_BUY = 'BUY'
    QUOTE_TYPE_SELL = 'SELL'
    
    # get latest Switchless Broker Ticker
    def ticker(pair)
      res = api_auth.get('/api/2/ticker', {pair: pair})
      r = JSON.parse(res.body) rescue nil
      
      raise Exceptions::BrokerError.new("Broker ticker error: #{r}") if r && r['error']
      raise Exceptions::BrokerError.new("Broker ticker error: #{res.status}") if res.status != 200 || r.nil?

      {
      timestamp:  to_datetime(r['timestamp']),
      bid:        BigDecimal.new(r['bid']),
      ask:        BigDecimal.new(r['ask']),
      last:       BigDecimal.new(r['last'])
      }
    end

    # request a quote 
    def quote(pair, base_amount, quote_type)
      res = api_auth.post('/api/2/quote', {
          pair: pair,
          base_amount: base_amount.to_s,
          type: quote_type
        })
      r = JSON.parse(res.body) rescue nil

      raise Exceptions::BrokerError.new("Broker quote error: #{r}") if r && r['error']
      raise Exceptions::BrokerError.new("Broker quote error: #{res.status}") if res.status != 201 || r.nil?

      {
        id:             r["id"],
        type:           r["type"],
        pair:           r["pair"],
        base_amount:    r["base_amount"],
        counter_amount: r["counter_amount"],
        created_at:     to_datetime(r["created_at"]),
        expires_at:     to_datetime(r["expires_at"]),
        discarded:      r["discarded"],
        exercised:      r["exercised"]
      }
    end

    #Retrieve a quote
    def show(quote_id)
      res = api_auth.get("/api/2/quote/#{quote_id}")
      
      r = JSON.parse(res.body) rescue nil
      
      raise Exceptions::BrokerError.new("Broker quote error: #{r}") if r && r['error']
      raise Exceptions::BrokerError.new("Broker quote retrieve error: #{res.status}") if res.status != 200 || r.nil?

      {
        id:             r["id"],
        type:           r["type"],
        pair:           r["pair"],
        base_amount:    r["base_amount"],
        counter_amount: r["counter_amount"],
        created_at:     to_datetime(r["created_at"]),
        expires_at:     to_datetime(r["expires_at"]),
        discarded:      r["discarded"],
        exercised:      r["exercised"]
      }
    end

    #Exercise a quote
    def exercise(quote_id)
      res = api_auth.put("/api/2/quote/#{quote_id}")
      raise Exceptions::BrokerError.new("Broker quote exercise error: #{res.status}") if res.status != 200
      true
    end

    #discard a quote
    def discard(quote_id)
      res = api_auth.delete("/api/2/quote/#{quote_id}")
      raise Exceptions::BrokerError.new("Broker quote discard error: #{res.status}") if res.status != 200
      true
    end

  private

    def api
      options = {url: "http#{'s' unless @cert.blank?}://#{@host}:#{@port}"}
      unless @cert.blank?
        options.merge!({
          ssl: {
            ca_file: @cert
          }
        })
      end
      conn = Faraday.new(options)
      conn.headers[:user_agent] = "broker gem"
      conn.builder.response :logger, @logger
      conn
    end

    def api_auth        
      conn = api
      conn.basic_auth(@username, @password)
      conn
    end

    # Convert a unix timestamp to a datetime.
    def to_datetime(t)
      Time.at(t).to_datetime
    end

  end

end

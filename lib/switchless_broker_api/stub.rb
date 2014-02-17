module Stub
  class StubbedApi
  #TODO FARADAY STUBS

    def initialize
      @quotes = {}
    end

    def ticker(pair)
      if pair != 'XBTZAR'
        raise Exceptions::BrokerError.new('Unknown pair')
      end
      if Rails.env.test?
        return {bid: BigDecimal.new('1000'),
          ask: BigDecimal.new('1089'),
          last: BigDecimal.new('1040')}
      else
        return {bid: BigDecimal.new('9262.87'),
          ask: BigDecimal.new('9499.86'),
          last: BigDecimal.new('9381')}
      end
    end

    QUOTE_TYPE_BUY = Broker::Api::QUOTE_TYPE_BUY
    QUOTE_TYPE_SELL = Broker::Api::QUOTE_TYPE_SELL

    def quote(pair, base_amount, quote_type)
      if pair != 'XBTZAR'
        raise Exceptions::BrokerError.new('Unknown pair')
      end

      if quote_type == QUOTE_TYPE_BUY
        rate = ticker(pair)[:ask]
      elsif quote_type == QUOTE_TYPE_SELL
        rate = ticker(pair)[:bid]
      else
        raise Exceptions::BrokerError.new('Invalid quote_type')
      end

      q = {
        id: SecureRandom.random_number(2**63),
        expires_at: Time.current + 5.minutes,
        exercised: false,
        discarded: false,
        type: quote_type,
        base_amount: BigDecimal(base_amount, 16),
        counter_amount: BigDecimal(base_amount, 16) * rate}
      @quotes[q[:id]] = q
      q
    end

    def exercise(quote_id)
      q = @quotes[quote_id]
      if Time.current > q[:expires_at]
        raise Exceptions::BrokerError.new('Quote has expired')
      end
      if q[:exercised]
        raise Exceptions::BrokerError.new('Quote already exercised')
      end
      if q[:discarded]
        raise Exceptions::BrokerError.new('Quote already discarded')
      end
      q[:exercised] = true
      @quotes[q[:id]] = q
      q
    end

    def discard(quote_id)
      q = @quotes[quote_id]
      if Time.current > q[:expires_at]
        raise Exceptions::BrokerError.new('Quote has expired')
      end
      if q[:exercised]
        raise Exceptions::BrokerError.new('Quote already exercised')
      end
      if q[:discarded]
        raise Exceptions::BrokerError.new('Quote already discarded')
      end
      q[:discarded] = true
      @quotes[q[:id]] = q
      q
    end

  end
end
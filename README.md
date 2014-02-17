# SwitchlessBrokerApi

This is a gem that exercises the Switchless Broker API.
The Broker API provides quotes for buying or selling Bitcoin; and allows execution of the quotes.
Customers need to maintain a float or have a settlement aggreement with Switchless.
You get API access by being a trusted Switchless partner.
Email info@switchless.com for more details.

## Installation

Add this line to your application's Gemfile:

    gem 'switchless_broker_api', git: 'https://github.com/Switchless/switchless_broker_api_gem.git'

And then execute:

    $ bundle

## Usage

include the following broker.rb file as a library dependency in your project.
Get the settings as is appropriate for your project

    module Broker
      # Return the default Broker instance.
      def Broker.get
        unless Rails.env.production?
          @@instance ||= Broker::StubbedApi.new
          return @@instance
        end

        @@instance ||= Broker::Api.new(
          Settings.broker.host,
          Settings.broker.port,
          Settings.broker.username,
          Settings.broker.password,
          Settings.broker.cert,
          Logger.new("#{Rails.root}/log/broker.log")
        @@instance
      end
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

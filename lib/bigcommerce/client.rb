require 'faraday'
require 'faraday_middleware'
require 'hashie/mash'
require 'inflection'

module Bigcommerce

  class Client

    attr_reader :store_url, :username, :api_token

    def initialize(options={})
      raise(ArgumentError, "Must provide both store url, username, and api token") unless options.has_key?(:username) && options.has_key?(:api_token) && options.has_key?(:store_url)
      @store_url = options[:store_url]
      @username = options[:username]
      @api_token = options[:api_token]
    end

    # Get all members of a resource

    def categories(params={})
      objects = get('/categories.json', params).body
    end

    def brands(params={})
      objects = get('/brands.json', params).body
    end

    def countries(params={})
      objects = get('/countries.json', params).body
    end

    def customers(params={})
      objects = get('/customers.json', params).body
    end

    def options(params={})
      objects = get('/options.json', params).body
    end

    def option_sets(params={})
      objects = get('/optionsets.json', params).body
    end

    def orders(params={})
      objects = get('/orders.json', params).body
    end

    def order_statuses(params={})
      objects = get('/orderstatuses.json', params).body
    end

    def request_logs(params={})
      objects = get('/requestlogs.json', params).body
    end

    def time(params={})
      objects = get('/time', params).body
    end

    # Individual resource

    def product(params={})
      raise(ArgumentError, "Must provide an id") unless params[:id]
      get(['/products', params[:id]].join('/')).body
    end

    # create an asset

    def create_product(params)
      raise(ArgumentError, "Must provide product attributes") unless params
      post('/products', params).body
    end

    # update an asset

    def update_product(params)
      raise(ArgumentError, "Must provide a product") unless params
      put("/product", params).body
    end

    # delete an asset

    def delete_product(params)
      raise(ArgumentError, "Must provide a product") unless params
      delete("/products", params).body
    end

  end

  class Resource

    def initialize(client, attributes = {})
      #raise "Expected a Hash for attributes, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @client = client
      @klass = self.class.name.split('::').last
    end

    def all(params={})
      objects = get("/#{::Inflection.plural(@klass).downcase}.json", params).body
    end

    private

    # Perform an HTTP DELETE request
    def delete(path, params={}, options={})
      request(:delete, path, params, options)
    end

    # Perform an HTTP GET request
    def get(path, params={}, options={})
      request(:get, path, params, options)
    end

    # Perform an HTTP POST request
    def post(path, params={}, options={})
      request(:post, path, params, options)
    end

    # Perform an HTTP UPDATE request
    def put(path, params={}, options={})
      request(:put, path, params, options)
    end

    def request(method, path, params = {}, options = {})
      conn = Faraday::Connection.new @client.store_url
      conn.basic_auth @client.username, @client.api_token
      conn.response :logger
      conn.response :mashify
      conn.response :json, :content_type => /\bjson$/
      res = conn.send(method, "/api/v2/#{path}") do |req|
        if method == :post
          req.body = params[:body]
        else
          req.params = params
        end
      end
    end

  end

  class Product < Resource
  end
  class Category < Resource
  end
  class Brand < Resource
  end
  class Country < Resource
  end
  class Customer < Resource
  end
  class Option < Resource
  end
  class OptionSet < Resource
  end
  class Order < Resource
  end
  class OrderStatus < Resource
  end
  class RequestLog < Resource
  end


end
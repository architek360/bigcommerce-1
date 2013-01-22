require 'faraday'
require 'faraday_middleware'
require 'hashie/mash'
require 'inflection'

module Bigcommerce

  class Client

    attr_reader :store_url, :username, :api_token

    def initialize(options={})
      raise(ArgumentError, "Must provide store url, username, and api token") unless options.has_key?(:username) && options.has_key?(:api_token) && options.has_key?(:store_url)
      @store_url = options[:store_url]
      @username = options[:username]
      @api_token = options[:api_token]
    end

    # Get all members of a resource

    def time(params={})
      objects = get('/time', params).body
    end

  end

  class Resource

    def initialize(client, options = {})
      #raise "Expected a Hash for attributes, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @client = client
      @klass = ::Inflection.plural(self.class.name.split('::').last).downcase
    end

    def all(params={})
      @parent = params.select{|k,v| k.to_s.match(/_id$/)}
      parent_id = params.delete(@parent.keys.first) if @parent
      get("/#{[::Inflection.plural(@parent.keys.first.to_s[0..-4]).downcase.presence, @parent.values.first.presence, @klass].compact.join('/')}.json", params).body
    end

    def find(params={})
      @parent = params.select{|k,v| k.to_s.match(/_id$/)}
      parent_id = params.delete(@parent.keys.first) if @parent
      # need to remove anything extraneous from params like :id
      @id = params.delete(:id)
      get("/#{[::Inflection.plural(@parent.keys.first.to_s[0..-4]).downcase.presence, @parent.values.first.presence, @klass, @id.presence].compact.join('/')}.json", params).body
    end

    def create(params={})
      raise(ArgumentError, "Must provide product attributes") unless params
      @parent = params.select{|k,v| k.to_s.match(/_id$/)}
      parent_id = params.delete(@parent.keys.first) if @parent
      post("/#{[::Inflection.plural(@parent.keys.first.to_s[0..-4]).downcase.presence, @parent.values.first.presence, @klass].compact.join('/')}", params).body
    end

    def update(params={})
      raise(ArgumentError, "Must provide product attributes") unless params
      @parent = params.select{|k,v| k.to_s.match(/_id$/)}
      parent_id = params.delete(@parent.keys.first) if @parent
      @id = params.delete(:id)
      put("/#{[::Inflection.plural(@parent.keys.first.to_s[0..-4]).downcase.presence, @parent.values.first.presence, @klass, @id.presence].compact.join('/')}", params).body
    end

    def destroy(params={})
      raise(ArgumentError, "Must provide a product") unless params
      @parent = params.select{|k,v| k.to_s.match(/_id$/)}
      parent_id = params.delete(@parent.keys.first) if @parent
      # need to remove anything extraneous from params like :id
      delete("/#{[::Inflection.plural(@parent.keys.first.to_s[0..-4]).downcase.presence, @parent.values.first.presence, @klass, params[:id]].compact.join('/')}").body
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
      conn.response :json
      res = conn.send(method, "/api/v2/#{path}") do |req|
        req.headers['Content-Type'] = 'application/json'
        if method == :get
          req.params = params
        else
          req.body = params.to_json
        end
      end
    end

  end

  class Product < Resource
  end
  class Image < Resource
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
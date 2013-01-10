require 'faraday'
require 'faraday_middleware'
require 'hashie/mash'

module Bigcommerce

  class Client

    def initialize(options={})
#      raise(ArgumentError, "Must provide both store url, username, and api token") unless options.has_key?(:username) && options.has_key?(:api_token) && options.has_key?(:store_url)
      @store_url = options[:store_url]
      @username = options[:username]
      @api_token = options[:api_token]
    end

    # Get all assets of a type

    def products(params={})
      objects = get('/products.json', params).body
    end

    def categories(params={})
      objects = get('/categories.json', params).body
    end

    # Individual asset

    def story(id)
      raise(ArgumentError, "Must provide an asset id") unless id
      get(['/rest-1.v1/Data/Defect', id].join('/')).body['Asset']
    end

    # create an asset

    def create_story(params)
      puts "VersionOne GEM"
      puts params.inspect
      raise(ArgumentError, "Must provide an asset") unless params
      params[:body] = build_story(params).to_xml
      post('/rest-1.v1/Data/Defect', params, 'Content-Type' => 'application/xml').body
    end

    # update an asset

    def update_story(params)
      raise(ArgumentError, "Must provide an asset") unless params
      params[:body] = build_story(params).to_xml
      post("/rest-1.v1/Data/Defect/#{params[:id].gsub(':','/')}", params, 'Content-Type' => 'application/xml').body
    end

    # delete an asset

    def delete_story(params)
      raise(ArgumentError, "Must provide an asset") unless params
      post("/rest-1.v1/Data/Defect/#{params[:id].split(':').second}?op=Delete", params, 'Content-Type' => 'application/xml').body
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
      conn = Faraday::Connection.new @store_url
      conn.basic_auth @username, @api_token
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

end
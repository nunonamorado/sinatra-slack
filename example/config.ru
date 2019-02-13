require "rubygems"
require "sinatra"
require "pry"
require "eventmachine"

require File.expand_path '../app.rb', __FILE__

def run(opts)

  # Start he reactor
  EM.run do

    # define some defaults for our app
    server  = opts[:server] || 'thin'
    host    = opts[:host]   || '0.0.0.0'
    port    = opts[:port]   || '3000'
    web_app = opts[:app]

    # create a base-mapping that our application will set at. If I
    # have the following routes:
    #
    #   get '/hello' do
    #     'hello!'
    #   end
    #
    #   get '/goodbye' do
    #     'see ya later!'
    #   end
    #
    # Then I will get the following:
    #
    #   mapping: '/'
    #   routes:
    #     /hello
    #     /goodbye
    #
    #   mapping: '/api'
    #   routes:
    #     /api/hello
    #     /api/goodbye
    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    # NOTE that we have to use an EM-compatible web-server. There
    # might be more, but these are some that are currently available.
    unless ['thin', 'hatetepe', 'goliath'].include? server
      raise "Need an EM webserver, but #{server} isn't"
    end

    # Start the web server. Note that you are free to run other tasks
    # within your EM instance.
    Rack::Server.start({
      app:    dispatch,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })
  end
end

run app: App.new

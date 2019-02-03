require "sinatra/base"
require_relative "./slack/command"
require_relative "./slack/request"

module Sinatra
  module Slack    

    @@commands = []
    @@actions = []

    def commands_endpoint(path)               
      settings.post(path) do        
        content_type "application/x-www-form-urlencoded"
        
        # in case someone already read it
        request.body.rewind
        # just to be sure that Slack payload is correctly decoded
        decoded = URI.decode(request.body.read)
        data = URI.decode_www_form(decoded).to_h      
        
        logger.info "Received: #{data}"

        args = data["command"][1..-1].split(" ")
        command_name = args.first.to_sym
        command = @@commands.find {|c| c.name == command_name}

        halt 400, "Unknown Command" unless command        

        if command.subcommands.size > 0
          # validate subcommands and execute
        else                    
          slack_req = Slack::Request.new(self, args.drop(1))
          return command.handler.call(slack_req)
        end

        200
      end
    end

    def configure_command(name, options={}, &block)    
      command = Slack::Command.new(name, options)
      @@commands << command
      yield command if block_given?          
    end

    def handle_command(name, &block)
      command = @@commands.find {|c| c.name == name}
      command.handler = block if command && block_given?
    end

    def actions_endpoint(path)      
      settings.post(path) { 
        "this is the actions endpoint" 
      }
    end
  end

  register Slack
end
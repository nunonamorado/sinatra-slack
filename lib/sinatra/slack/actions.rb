require "sinatra/base"
require "mustermann"

module Sinatra
  module SlackActions 
    def actions_endpoint(path)
      settings.post(path) { 
        "this is the actions endpoint" 
      }
    end
    
    def action(action, &block)
      @actions ||= []
    end    
  end

  register SlackActions
end


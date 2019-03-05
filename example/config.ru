#\ -w -p 3000
# frozen_string_literal: true

require 'rubygems'
require 'pry'
require 'dotenv/load'

require File.expand_path 'app.rb', __dir__

run App.new

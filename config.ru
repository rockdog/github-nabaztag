require 'rubygems'
require 'sinatra'

log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

require 'github_nabaztag'
run Sinatra::Application

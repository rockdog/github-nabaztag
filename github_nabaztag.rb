require 'rubygems'
require 'net/http'
require 'yaml'
require 'json'
require 'sinatra'

CONF = YAML.load_file('config.yml')

class GithubNabaztag
  
  API_URL = 'http://api.nabaztag.com/vl/FR/api.jsp'
  
  def initialize(payload)
    payload = JSON.parse(payload)
    @repository = payload['repository']
    @commits = payload['commits']
    send
  end
  
  def message
    msg = "Repository #{@repository['name']} received new commits. "
    msg += @commits.collect { |hash, commit| "#{commit['author']['name']} committed: #{commit['message']}"}.join('. ')
    msg += "."
    msg
  end
    
  def send
    uri = URI.parse(API_URL)
    
    params = {
      'sn' => CONF['key'],
      'token' => CONF['token'],
      'voice' => 'UK-Shirley',
      'tts' => URI.encode(message)
    }

    response = Net::HTTP.start(uri.host, uri.port) { |http|
      http.request(Net::HTTP::Get.new(uri.path + "?" + params.collect {|k,v| "#{k.to_s}=#{v}" }.join('&')))
    }
    
    response.body
  end
  
end


get '/' do
  'Hello World!'
end

post '/' do
  GithubNabaztag.new(params[:payload])
end

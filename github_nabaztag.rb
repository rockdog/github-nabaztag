require 'rubygems'
require 'net/http'
require 'json'
require 'sinatra'

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
    
    # http://api.nabaztag.com/docs/home.html
    params = {
      'sn' => ENV['NABAZTAG_API_SERIAL'],
      'token' => ENV['NABAZTAG_API_TOKEN'],
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
  puts params.inspect
  # GithubNabaztag.new(params[:payload])
end

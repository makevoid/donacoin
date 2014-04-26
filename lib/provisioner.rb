require 'json'
require 'net/http'

class Provisioner
  URL         = "/miner"
  NOTIFY_URL  = "/notify_mining"
  
  attr_reader :host
  
  def initialize(host)
    @host = host
  end
  
  def provision_settings 
    #uri = URI("http://#{host}/#{URL}")  
    #Net::HTTP.get uri
    uri = URI.parse "http://#{host}#{URL}"
    resp = Net::HTTP.get_response uri
    body = resp.body
    JSON.parse body
  end
  
  def notify_mining(params)
    uri = URI.parse "http://#{host}#{NOTIFY_URL}"
    Net::HTTP.post_form uri, params
    puts params
    # url = 
    # params.to_json
  end
end

# host = "localhost:3000"   # dev
# host = "mkvd-32284.euw1.nitrousbox.com" # nitrous
# #host = "api.donacoin.com" # prod
# prov = Provisioner.new host
# puts prov.provision
# puts prov.provision["pool"]
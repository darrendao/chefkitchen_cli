require 'rubygems'
require 'rest-client'
require 'json'
require 'cookie_jar'

class RequestHelper
  include CookieJar

  def initialize(conf)
    @server = conf[:server] || "localhost"
    @username = conf[:username]
    @password = conf[:password]
    @cookies = get_cookies
  end

  def create_tag(options)
    revision = options[:revision]
    nodegroup = options[:nodegroup]
    begin
      response = RestClient.post("http://#{@server}/tags", 
                                 {:tag => {:revision => revision, :nodegroup => nodegroup}}, 
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts "http://#{@server}/tags/#{result['tag']['id']}"
    rescue => e
      puts e.inspect
    end
  end

  def dryrun(options)
    tag = options[:tag]
    nodegroup = options[:nodegroup]
    begin
      response = RestClient.post("http://#{@server}/diff_requests",
                                 {:diff_request => 
                                    {'dryruns_attributes[0][node_group]' => options[:nodegroup1], 'dryruns_attributes[0][tag]' => options[:tag1], 
                                     'dryruns_attributes[1][node_group]' => options[:nodegroup2], 'dryruns_attributes[1][tag]' => options[:tag2]}
                                     
                                 },
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts "http://#{@server}/dryruns/#{result['dryrun']['id']}"
    rescue => e
      puts e.inspect
    end
  end  

  def diffrun(options)
  end
end

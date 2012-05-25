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

  def tag(options)
    revision = options[:revision]
    nodegroup = options[:nodegroup]
    begin
      response = RestClient.post("http://#{@server}/tags", 
                                 {:tag => {:revision => revision, :nodegroup => nodegroup}}, 
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts "Tag id: #{result['tag']['id']}"
      puts "URL: http://#{@server}/tags/#{result['tag']['id']}"
    rescue => e
      puts e.inspect
    end
  end

  def diffrun(options)
    begin
      response = RestClient.post("http://#{@server}/diff_requests",
                                 {:diff_request => 
                                    {'dryruns_attributes[0][node_group]' => options[:nodegroup1], 'dryruns_attributes[0][tag]' => options[:tag1], 
                                     'dryruns_attributes[1][node_group]' => options[:nodegroup2], 'dryruns_attributes[1][tag]' => options[:tag2]}
                                     
                                 },
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts "http://#{@server}/diff_requests/#{result['diff_request']['id']}"
    rescue => e
      puts e.inspect
    end
  end  

  def dryrun(options)
    tag = options[:tag]
    nodegroup = options[:nodegroup]
    begin
      response = RestClient.post("http://#{@server}/dryruns",
                                 {:dryrun => {'node_group' => nodegroup, :tag => tag}},
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts "http://#{@server}/dryruns/#{result['dryrun']['id']}"
    rescue => e
      puts e.inspect
    end
  end

  def show_dryrun(options)
    begin
      response = RestClient.get("http://#{@server}/dryruns/#{options[:id]}",
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        display_dryrun(result)
      end
    rescue => e
      puts e.inspect
    end
  end

  def show_diffrun(options)
    begin
      response = RestClient.get("http://#{@server}/diff_requests/#{options[:id]}",
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      if options[:json]
        puts JSON.pretty_generate(result)
      else
        display_diff(result)
      end
    rescue => e
      puts e.inspect
    end
  end

  def show_tag(options)
    begin
      response = RestClient.get("http://#{@server}/tags/#{options[:id]}",
                                 {:cookies => @cookies, :content_type => 'application/json', :accept => :json})
      result = JSON.parse(response)
      puts JSON.pretty_generate(result)
         
    rescue => e
      puts e.inspect
    end
  end

  private
  def display_diff(diffs)
    diffs.each do |key, value|
      value.each do |diff|
        puts diff['diff']
        puts "\n"     
      end
    end
  end

  def display_dryrun(result)
    puts "Dryrun info: "
    puts JSON.pretty_generate(result['dryrun'])
    puts "\n"
    puts "Files generated: "
    result['files'].each do |file|
      puts file['path']
    end
  end
end

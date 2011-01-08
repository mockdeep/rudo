# an attempt to poke around with Remember the Milk
require 'net/http'
require 'md5'
require 'cgi'
require 'uri'
require 'cred'
require 'rubygems'
require 'xml/libxml'

class Milker
  include Cred

  def self.get_list

    # initially we're just looking to get a list of the tasks
    @uri = URI.parse("http://api.rememberthemilk.com/services/rest/")
    args={'api_key' => API_KEY, 'method' => 'rtm.tasks.getList'}
    #sig = MD5.md5(API_SHARED_SECRET + args.sort.flatten.join).to_s
    sig = get_signed(args)
    puts "@uri.host: #{@uri.host} - @uri.path: #{@uri.path}"
    puts "let's see if we can get a response:"
    response = Net::HTTP.get_response(@uri.host, "#{@uri.path}?method=rtm.tasks.getList&api_key=#{API_KEY}&api_sig=#{sig}")
    #response = Net::HTTP.get_response(@uri.host, "#{@uri.path}?api_key=#{API_KEY}&api_sig=#{sig}")
    puts "----------------------------------------------------------------"
    puts response.inspect
    puts response.body
  end

  def self.get_frob
    @uri = URI.parse("http://api.rememberthemilk.com/services/rest/")
    args = { 'api_key' => API_KEY, 'method' => 'rtm.auth.getFrob' }
    sig = get_signed(args)
    response = Net::HTTP.get_response(@uri.host, "#{@uri.path}?method=rtm.auth.getFrob&api_key=#{API_KEY}&api_sig=#{sig}")
    puts response.inspect
    puts "response class: " + response.class.to_s
    puts "response body class: " + response.body.class.to_s
    puts response.body
    get_xml_element('frob', response.body)
  end

  def self.get_xml_element(elem, string)
    #context = XML::Parser::Context.new
    parser = XML::Parser.string(string)
    doc = parser.parse
    doc.find(elem).first.content
  end

  def self.get_signed(args)
    MD5.md5(API_SHARED_SECRET + args.sort.flatten.join).to_s
  end

  def self.get_auth
    frob = self.get_frob
    @uri = URI.parse("http://www.rememberthemilk.com/services/auth/")
    args = { 'api_key' => API_KEY, 'perms' => 'read', 'frob' => frob }
    args['api_sig'] = get_signed(args)
    address = "#{@uri.host}#{@uri.path}?#{args.keys.collect {|k| "#{CGI::escape(k).gsub(/ /,'+')}=#{CGI::escape(args[k]).gsub(/ /,'+')}"}.join('&')}"
    puts address.to_s
  end

end
Milker.get_auth
#puts "here's your frob: " + Milker.get_frob

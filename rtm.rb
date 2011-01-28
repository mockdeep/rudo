# an attempt to poke around with Remember the Milk
require 'net/http'
require 'md5'
require 'cgi'
require 'uri'
require File.join(File.dirname(__FILE__), 'cred')
require 'rubygems'
require 'xml/libxml'
require 'json'

class Milker
  # I've put my credentials and bits of info in a separate file
  # This file is ignored by git.  Wouldn't want somebody using it to foul purposes
  # in order to work with this you'll need to get your own, follow instructions at
  # http://www.rememberthemilk.com/services/api/authentication.rtm
  # TODO: the TOKEN should be moved out of cred.rb to the database
  include Cred

  def initialize
    @uri = URI.parse("http://api.rememberthemilk.com/services/rest/")
    @token = TOKEN
  end

  def get_frob
    args = { 'api_key' => API_KEY, 'method' => 'rtm.auth.getFrob' }
    sig = get_signed(args)
    response = Net::HTTP.get_response(@uri.host, "#{@uri.path}?method=rtm.auth.getFrob&api_key=#{API_KEY}&api_sig=#{sig}")
    puts response.inspect
    puts "response class: " + response.class.to_s
    puts "response body class: " + response.body.class.to_s
    puts response.body
    @frob ||= get_xml_element('frob', response.body)
  end

  def get_xml_element(elem, string)
    parser = XML::Parser.string(string)
    doc = parser.parse
    puts doc.to_s
    doc.find(elem).first.content
  end

  def get_signed(args)
    MD5.md5(API_SHARED_SECRET + args.sort.flatten.join).to_s
  end

  def standard_args
    args = { 'api_key' => API_KEY, 'auth_token' => @token, 'format' => 'json' }
  end

  def get_auth
    auth_uri = URI.parse("http://www.rememberthemilk.com/services/auth/")
    args = { 'api_key' => API_KEY, 'perms' => 'read', 'frob' => get_frob }
    args['api_sig'] = get_signed(args)
    address = "#{auth_uri.host}#{auth_uri.path}?#{args.keys.collect {|k| "#{CGI::escape(k).gsub(/ /,'+')}=#{CGI::escape(args[k]).gsub(/ /,'+')}"}.join('&')}"
    puts address.to_s
    puts 'go to the above address to authenticate, then hit Enter'
    gets
  end

  def get_token
    get_auth
    args = { 'api_key' => API_KEY, 'frob' => get_frob, 'method' => 'rtm.auth.getToken' }
    args['api_sig'] = get_signed(args)
    response = Net::HTTP.get_response(@uri.host, "#{@uri.path}?#{args.keys.collect {|k| "#{CGI::escape(k).gsub(/ /,'+')}=#{CGI::escape(args[k]).gsub(/ /,'+')}"}.join('&')}")
    puts response.inspect
    puts response.body
    token = get_xml_element('token', response.body)
    puts "Token: " + token.to_s
  end

  def get_lists
    args = standard_args.merge('method' => 'rtm.lists.getList')
    args['api_sig'] = get_signed(args)
    response = get_response(args)
    puts response.inspect
    puts response.body
  end

  def get_all_tasks
    args = standard_args.merge('method' => 'rtm.tasks.getList')
    args['api_sig'] = get_signed(args)
    response = get_response(args)
    puts response.inspect
    puts response.body
  end

  def get_todays_tasks
    args = standard_args.merge('method' => 'rtm.tasks.getList', 'filter' => "status:incomplete AND (dueBefore:today OR due:today)")
    args['api_sig'] = get_signed(args)
    response = get_response(args)
    body = JSON.parse(response.body)['rsp']['tasks']['list']
    parse_lists(body)
  end

  def parse_lists(lists)
    ourlist = []
    if lists.is_a? Hash
      ourlist += parse_series(lists['taskseries'])
    else
      lists.each do |list|
        ourlist += parse_series(list['taskseries'])
      end
    end
    ourlist
  end

  def parse_series(series)
    ourseries = []
    if series.is_a? Array
      series.each do |item|
        ourseries << item['name']
      end
    else
      ourseries << series['name']
    end
    ourseries
  end

  def check_token
    args = { 'api_key' => API_KEY, 'method' => 'rtm.auth.checkToken', 'auth_token' => @token }
    args['api_sig'] = get_signed(args)
    response = get_response(args)
    puts response.inspect
    puts response.body
  end

  def get_response(args)
    Net::HTTP.get_response(@uri.host, "#{@uri.path}?#{args.keys.collect {|k| "#{CGI::escape(k).gsub(/ /,'+')}=#{CGI::escape(args[k]).gsub(/ /,'+')}"}.join('&')}")
  end
end

class List
  def rtm_add
    a = Milker.new
    a.get_todays_tasks.each do |task|
      add(task)
    end
  end
end

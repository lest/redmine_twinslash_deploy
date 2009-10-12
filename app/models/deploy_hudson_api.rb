require 'net/http'
require 'net/https'
require 'rexml/document'
require 'uri'

class DeployHudsonApi
  unloadable

  def base_url
    Setting.plugin_redmine_twinslash_deploy['hudson_base_url']
  end

  def create_job(template, ident, svn_path, name, users = [])
    xml = REXML::Document.new(File.new(Setting.plugin_redmine_twinslash_deploy['template_dir'] + '/' + template + '/hudson.xml'))
    permissions = xml.root.elements['properties/hudson.security.AuthorizationMatrixProperty']
    users.each do |user|
      read_permission = REXML::Element.new('permission')
      read_permission.text = "hudson.model.Item.Read:#{user}"
      permissions.elements << read_permission
      build_permission = REXML::Element.new('permission')
      build_permission.text = "hudson.model.Item.Build:#{user}"
      permissions.elements << build_permission
    end

    config = xml.to_s
    config.gsub!(/\{name\}/, name)
    config.gsub!(/\{ident\}/, ident)
    config.gsub!(/\{svn_path\}/, svn_path)

    url = URI.parse("#{base_url}/createItem")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(url.path + "?name=#{ident}")
    req.basic_auth(url.user, url.password)
    req.content_type = 'text/xml; charset=UTF-8'
    req.body = config
    res = http.request(req)
  end

  def delete_job(ident)
    url = URI.parse("#{base_url}/job/#{ident}/doDelete")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(url.user, url.password)
    req.content_type = 'text/xml; charset=UTF-8'
    res = http.request(req)
  end

  def read_job_config(ident)
    url = URI.parse("#{base_url}/job/#{ident}/config.xml")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(url.path)
    req.basic_auth(url.user, url.password)
    res = http.request(req)
    res.body
  end

  def write_job_config(ident, config)
    url = URI.parse("#{base_url}/job/#{ident}/config.xml")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth(url.user, url.password)
    req.content_type = 'text/xml; charset=UTF-8'
    req.body = config
    res = http.request(req)
  end

  def add_user_to_job(ident, user)
    config = read_job_config(ident)
    xml = REXML::Document.new(config)
    permissions = xml.root.elements['properties/hudson.security.AuthorizationMatrixProperty']
    read_permission = REXML::Element.new('permission')
    read_permission.text = "hudson.model.Item.Read:#{user}"
    permissions.elements << read_permission
    build_permission = REXML::Element.new('permission')
    build_permission.text = "hudson.model.Item.Build:#{user}"
    permissions.elements << build_permission
    config = xml.to_s
    write_job_config(ident, config)
  end

  def remove_user_from_job(ident, user)
    config = read_job_config(ident)
    xml = REXML::Document.new(config)
    xml.root.elements.each('//properties/hudson.security.AuthorizationMatrixProperty/permission') do |element|
      element.remove if element.text.split(':')[1] == user
    end
    config = xml.to_s
    write_job_config(ident, config)
  end
end

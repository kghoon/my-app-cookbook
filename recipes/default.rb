#
# Cookbook Name:: my-app
# Recipe:: default
#
# Copyright (c) 2016 Jihoon Kang, All Rights Reserved.
include_recipe 'java'

app_name = node['my-app']['name']

tomcat_install app_name do
  version '8.0.32'
end

directory "/opt/tomcat_#{app_name}/webapps/ROOT" do
    action :delete
    recursive true
    notifies :restart, "tomcat_service[#{app_name}]", :delayed
end

remote_file "/opt/tomcat_#{app_name}/webapps/ROOT.war" do
    source node['my-app']['war']
    user "tomcat_#{app_name}"
end

tomcat_service app_name do
    action :start
end

include_recipe 'nginx'

template "#{node['nginx']['dir']}/sites-available/#{app_name}" do
    source 'nginx-proxy.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
        :proxied_port => 8080,
        :default => true,
    )
    action :create
end

nginx_site app_name


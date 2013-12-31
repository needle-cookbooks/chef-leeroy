#
# Cookbook Name:: leeroy
# Recipe:: default
#
# Copyright (C) 2013 Needle Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'python::default'
include_recipe 'runit::default'

leeroy = node['leeroy']

group leeroy['group']

user leeroy['user'] do
  home leeroy['home']
  system true
  gid leeroy['group']
end

venv_path = ::File.join(leeroy['home'], 'env')

[ leeroy['home'], venv_path ].each do |dir|
  directory dir do
    owner leeroy['user']
    group leeroy['group']
    recursive true
    mode 00750
  end
end

python_virtualenv venv_path do
  owner leeroy['user']
  group leeroy['group']
  action :create
end

%w{ gunicorn leeroy }.each do |pkg|
  python_pip pkg do
    virtualenv venv_path
    action :install
  end
end

gunicorn_py_path = ::File.join(leeroy['home'], 'gunicorn.py')

gunicorn_config gunicorn_py_path do
  owner leeroy['user']
  group leeroy['group']
  listen leeroy['listen']
  action :create
end

settings_py_path = ::File.join(leeroy['home'], 'settings.py')

template settings_py_path do
  owner leeroy['user']
  group leeroy['group']
  variables({
    debug: leeroy['debug'],
    server_name: node['fqdn'],
    github_api_base: leeroy['github_api_base'],
    github_ssl_verify: leeroy['github_ssl_verify'],
    github_token: leeroy['github_token'],
    jenkins_url: leeroy['jenkins_url'],
    jenkins_username: leeroy['jenkins_username'],
    jenkins_password: leeroy['jenkins_password'],
    build_commits: leeroy['build_commits'],
    repository_map: leeroy['repository_map']
  })
end

runit_service 'leeroy' do
  options({
    :user => leeroy['user'],
    :home => leeroy['home'],
    :venv => venv_path
  })
  [ gunicorn_py_path, settings_py_path ].each do |name|
    subscribes :restart, "template[#{name}]"
  end
end

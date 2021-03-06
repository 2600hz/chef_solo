#
# Cookbook Name:: rsyslog
# Recipe:: whistle
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node[:platform]
when "centos", "redhat"
  service "syslog" do
    action [:stop, :disable ]
  end
end

package "rsyslog" do
  action :install
end

service "rsyslog" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

cookbook_file "/etc/default/rsyslog" do
  source "rsyslog.default"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/rsyslog.d" do
  owner "root"
  group "root"
  mode 0755
end

case node[:platform]
when "ubuntu"
  template "/etc/rsyslog.conf" do
    source "rsyslog.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "rsyslog"), :delayed
  end
  if node[:platform_version].to_f >= 9.10
    template "/etc/rsyslog.d/50-default.conf" do
      source "50-default.conf.erb"
      backup false
      owner "root"
      group "root"
      mode 0644
    end
  end
when "centos", "redhat"
  template "/etc/rsyslog.conf" do
    source "rsyslog.conf.whistle.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => "rsyslog"), :delayed
  end
end

%w{bluepill opensips 2600hz-platform haproxy}.each do |f|
  file "/var/log/#{f}.log" do
    mode 0644
  end
end

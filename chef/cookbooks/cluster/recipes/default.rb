include_recipe 'apt'
include_recipe 'docker'
include_recipe 'docker-compose'
include_recipe 'udrnginx'

# let's get the services alive
# execute 'bring up cluster' do
#   command  'docker run -d -p 127.0.0.1:1330:80 pnathan/articulate-common-lisp'
#   not_if 'docker ps | grep articulate-common-lisp'
# end

# for these 3 sites: use static files.

file '/etc/nginx/sites-available/pnathan.com.conf' do
  content %q{server {
listen 80;
server_name pnathan.com;
location / {
root /var/www/pnathan.com;
}
}
}
end

link '/etc/nginx/sites-enabled/pnathan.com.conf' do
  to '/etc/nginx/sites-available/pnathan.com.conf'
  notifies :reload, 'service[nginx]'
end

# nginx_site "faegernis.com" do
#   host "faegernis.com"
#   root "/var/www/faegernis.com"
# end

# nginx_site "upside-down-research.com" do
#   host "upside-down-research.com"
#   root "/var/www/upside-down-research.com"
# end

# file '/etc/nginx/sites-available/articulate-lisp.com.conf' do
#   content %q{server {
#   listen 80;
#   server_name articulate-lisp.com;


#   location / {
#     # app1 reverse proxy follow
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header Host $host;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_pass http://127.0.0.1:1330;
#   }
# }
# }
#   notifies :reload, 'service[nginx]'
# end

# link '/etc/nginx/sites-enabled/articulate-lisp.com.conf' do
#   to '/etc/nginx/sites-available/articulate-lisp.com.conf'
#   notifies :reload, 'service[nginx]'
# end

##############################
# finish the bootstrap.


file '/etc/apt/sources.list.d/canonical.list' do
  content %q{
###### Ubuntu Main Repos
deb http://us.archive.ubuntu.com/ubuntu/ trusty main

###### Ubuntu Update Repos
deb http://us.archive.ubuntu.com/ubuntu/ trusty-security main
deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main
deb http://us.archive.ubuntu.com/ubuntu/ trusty-backports main
}

  mode '0644'
  owner 'root'
  group 'root'
end


directory '/opt/udr' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# This is the file that we use to apply chef.
# It is a near-mimic of the user-data
file '/opt/udr/apply-latest-chef.sh' do
  content %q{#!/bin/bash -ex

function leaving {
  rm -f /tmp/chef.lock
}

echo $(date -R) "starting chef run"

trap leaving EXIT

if [ -e /tmp/chef.lock ]; then
  echo date -R "attempted chef run; chef run already running" >> /var/log/chef.log
  exit 0
fi

touch /tmp/chef.lock

mkdir -p /opt/udr/chef/
cd  /opt/udr/chef/
curl -O upside-down-research.s3-website-us-west-2.amazonaws.com/chef/udr.tgz
tar xzf udr.tgz
chef-client --no-color -l info -L /var/log/chef.log -z -o cluster
echo $(date -R) "finished chef run successfully"
}
  mode '0700'
  owner 'root'
  group 'root'
end

# have a logfile for cron
file '/etc/rsyslog.d/60-cron.conf' do
  content %q{
cron.*                         /var/log/cron.log
}
  mode '0644'
  owner 'root'
  group 'root'
end


# bounce rsyslog as soon as we have the syslog reconfigured
service "rsyslog" do
  supports :restart => true, :reload => true
  action :enable
  subscribes :reload, 'file[/etc/rsyslog.d/60-cron.conf]', :immediately
end


file '/opt/udr/get-pnathan.sh' do
  content %q{#!/bin/bash -ex

function leaving {
  rm -f /tmp/pnathan.lock
}

trap leaving EXIT

if [ -e /tmp/pnathan.lock ]; then
  echo date -R "attempted pnathan run; pnathan run already running" >> /var/log/sites.log
  exit 0
fi

touch /tmp/pnathan.lock

cd /tmp
curl -O upside-down-research.s3-website-us-west-2.amazonaws.com/chef/pnathan.tbz2
tar xjf pnathan.tbz2
mkdir -p  /var/www/
mv /var/www/pnathan.com  /var/www/pnathan.com-old
mv site /var/www/pnathan.com
rm -rf /var/www/pnathan.com-old
chown -R www-data /var/www
chmod -R go+r /var/www
}
  mode '0700'
  owner 'root'
  group 'root'
end

cron 'get-latest-pnathan.com' do
  minute '*/5'
  command '/opt/udr/get-pnathan.sh 2>&1 >> /var/log/sites.log'
  only_if do File.exist?("/opt/udr/get-pnathan.sh") end
  action :create
end


# now automating and self-updating
cron 'get-latest-chef' do
  minute '*/5'
  command "/opt/udr/apply-latest-chef.sh 2>&1 >> /var/log/chef-application.log"
  only_if do File.exist?("/opt/udr/apply-latest-chef.sh") end
  action :create
end

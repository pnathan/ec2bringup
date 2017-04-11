package 'nginx'

service 'nginx' do
  action :start
end

# Strip the default configurations

file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

file '/etc/nginx/conf.d/example_ssl.conf' do
  action :delete
end

file '/etc/nginx/sites-enabled/default' do
  action :delete
end

file '/etc/nginx/sites-available/default' do
  action :delete
end

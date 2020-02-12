log "Setup Nginx"

yum_repository 'nginx' do
    description 'nginx repo'
    baseurl 'https://nginx.org/packages/mainline/centos/7/$basearch/'
    gpgcheck false
    enabled true
end

package "nginx" do
    action :install
    package_name "nginx"
end

bash "Backup /etc/nginx/nginx.conf" do
    code <<-EOH
       cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
      EOH
    not_if { ::File.exist?('/etc/nginx/nginx.conf.bak') }
end

template "/etc/nginx/nginx.conf" do
    source 'nginx.conf.erb'
end

template "/etc/nginx/conf.d/#{node[:nginx][:server_name]}.conf" do
    source 'conf.d.erb'
    owner 'root'
    group 'root'
    mode '0644' 
end

service 'nginx' do
    action [:start, :enable]
end

log "Setup Php"

bash 'Configure Remi Repo' do
    code <<-EOH
      sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
      sudo yum-config-manager --enable remi-php74 
    EOH
end

%w{ php php-fpm php-mbstring php-pdo php-pdo_mysql }.each do |pkg|
    package pkg do
      action :install
    end
end

bash "Backup /etc/php-fpm.d/www.conf" do
    code <<-EOH
        cp /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.bak
     EOH
     not_if { ::File.exist?('/etc/php-fpm.d/www.conf.bak') }
end

template "/etc/php-fpm.d/www.conf" do
    source 'www.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
end

bash "Change Group of /var/lib/php/session" do
    code <<-EOH
        chown -R root:nginx /var/lib/php/session
    EOH
end

service "php-fpm" do
    action [:start, :enable]
end

Vagrant.configure(2) do |config|
  DATABASE_NAME="lnpm" # !!! CHANGE IT TO DB NAME !!!
  DATABASE_USER="lnpm" # !!! CHANGE IT TO DB USER NAME !!!
  DATABASE_PASSWORD="lnpm" # !!! CHANGE IT TO DB USER PASSWORD!!!

  NAME="lnpm" # !!! CHANGE IT TO YOUR PROJECT NAME !!!
  HOSTNAME=NAME+".loc"

  config.vm.box = "ubuntu/trusty64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.network "private_network", type: "dhcp"

  if Vagrant::Util::Platform.windows?
    config.vm.synced_folder "www", "/var/www/loc/" + NAME
  else
    config.vm.synced_folder "www", "/var/www/loc/" + NAME, type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc']
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid
  end

  config.vm.hostname = HOSTNAME

  # Hostnamager configuration
  config.hostmanager.enabled           = true
  config.hostmanager.manage_host       = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline   = false

  # Dinamic ip resolver for vagrant hostmanager plugin
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    begin
      buffer = '';
        vm.communicate.execute("/sbin/ifconfig") do |type, data|
        buffer += data if type == :stdout
      end

      ips = []
        ifconfigIPs = buffer.scan(/inet addr:(\d+\.\d+\.\d+\.\d+)/)
        ifconfigIPs[0..ifconfigIPs.size].each do |ip|
          ip = ip.first
          
          if Vagrant::Util::Platform.windows?
            next unless system "ping #{ip} -n 1 -w 100>nul 2>&1"
          else
            next unless system "ping -c1 -t1 #{ip} > /dev/null"
          end

          ips.push(ip) unless ips.include? ip
        end
        ips.first
      rescue StandardError => exc
        return
      end
  end

  # avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  config.vm.provision :shell, :path => "provision/enable-swap.sh"
  config.vm.provision :shell, :path => "provision/bootstrap.sh"
  config.vm.provision :shell, :path => "install-1404.sh"
  config.vm.provision :shell, :path => "provision/database.sh", :args => [DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD]
  config.vm.provision "shell", inline: 'echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"; echo ""; echo "Your project available by next link: http://'+HOSTNAME+'"; echo ""; echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"'
end

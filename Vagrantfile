Vagrant.configure(2) do |config|
  NAME="lnpm" # !!! CHANGE IT TO YOUR PROJECT NAME !!!
  DATABASE_NAME="lnpm" # !!! CHANGE IT TO DB NAME !!!
  DATABASE_USER="lnpm" # !!! CHANGE IT TO DB USER NAME !!!
  DATABASE_PASSWORD="lnpm" # !!! CHANGE IT TO DB USER PASSWORD!!!

  HOSTNAME=NAME+".loc"

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = HOSTNAME
  config.vm.network "private_network", type: "dhcp"

  # Virtualbox provider
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # Docker provider
  config.vm.provider "docker" do |d|
    config.ssh.port = 22
    d.build_dir = "vagrant-docker"
    d.has_ssh = true
  end

  # Shared folders configuration
  if Vagrant::Util::Platform.windows?
    if Vagrant.has_plugin?("vagrant-winnfsd")
      config.winnfsd.uid = 33 # www-data UID
      config.winnfsd.gid = 33 # www-data GID
      config.vm.synced_folder "www", "/www", type: "nfs", mount_options: ['rw',  'vers=3', 'tcp', 'fsc', 'async', 'nolock', 'noacl', 'nosuid']
    else
      config.vm.synced_folder "www", "/www"
    end
  else
    config.nfs.map_uid = Process.uid
    config.nfs.map_gid = Process.gid
    config.vm.synced_folder "www", "/www", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'fsc', 'async', 'nolock', 'noacl', 'nosuid']
  end

  # Hostnamager configuration
  config.hostmanager.enabled           = true
  config.hostmanager.manage_host       = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline   = false

  # Dinamic ip resolver for vagrant hostmanager plugin
  if Vagrant.has_plugin?("vagrant-hostmanager")
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

            next unless system "ping -c1 -t1 #{ip} > /dev/null"

            ips.push(ip) unless ips.include? ip
          end
          ips.first
        rescue StandardError => exc
          return
        end
    end
  end

  # Avoid possible request "vagrant@127.0.0.1's password:" when "up" and "ssh"
  config.ssh.password = "vagrant"

  # Env
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Setup vagrant base system
  config.vm.provision :shell, :path => "vagrant/provision/enable-swap.sh"
  config.vm.provision :shell, :path => "vagrant/provision/bootstrap.sh"

  # Install environment
  config.vm.provision :shell, :path => "install-1404.sh", :args => ["--www-root", "/www"]

  # Configure default database credentials
  config.vm.provision :shell, :path => "default/db.sh", :args => [DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD]

  # Finish
  config.vm.provision :shell, :path => "default/completion.sh", :args => [HOSTNAME, DATABASE_NAME, DATABASE_USER, DATABASE_PASSWORD]
end

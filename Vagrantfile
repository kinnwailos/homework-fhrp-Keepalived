Vagrant.configure("2") do |config|
  # Base box
  config.vm.box = "ubuntu/jammy64"

  # Provider settings (VirtualBox)
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 2
  end

  # Shared network settings for both VMs
  netmask = "255.255.255.0"

  config.vm.define "vm1" do |vm|
    vm.vm.hostname = "vm1"
    vm.vm.network "private_network",
      # VirtualBox 7.x defaults: host-only IPs must be in 192.168.56.0/21 (see /etc/vbox/networks.conf)
      ip: "192.168.56.10",
      netmask: netmask
  end

  config.vm.define "vm2" do |vm|
    vm.vm.hostname = "vm2"
    vm.vm.network "private_network",
      ip: "192.168.56.11",
      netmask: netmask
  end
end


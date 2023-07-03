VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision "shell", inline: "echo hello"

  config.vm.define "staging1" do |staging1|
    staging1.vm.box = "geerlingguy/ubuntu1604"
    staging1.vm.provider :virtualbox do |v|
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
  end

  config.vm.define "staging2" do |staging2|
    #libvirt/alpine38?
    staging2.vm.box = "generic/alpine38"
    staging2.vm.box_version = "4.2.16"
    staging2.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
  end

  config.vm.define "prod1" do |prod1|
    prod1.vm.box = "bento/ubuntu-18.04"
    prod1.vm.provider :virtualbox do |v|
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
  end

  # Define VMs with static private IP addresses
  boxes = [
    { :name => "agent1", ip => "192.168.42.91"},
    { :name => "agent2", ip => "192.168.42.92"},
    { :name => "agent3", ip => "192.168.42.93"}
  ]

  # Provision each of the VMs
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network :private_network, ip: opts[:ip]

      # provision all vms in parallel with ansible when the last VM is up
      if opts[:name] == "agent3"
        config.vm.provision "ansible" do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.playbook = "./playbooks/main.yaml"
          ansible.limit = "all"
          ansible.become = "true"
          ansible.groups = {
              "kubernetes" => ["agent1", "agent2", "agent3"],
              "kubernetes_master" => ["agent1"],
              "kubernetes_master:vars" => {
                  kubernetes_role: "master",
                  # check this
                  swapfile_path: "/dev/mapper/vagrant--vg-swap_1",
                  kubernetes_apiserver_advertise_address: "192.168.56.71"
              },
              "kubernetes_node" => ["agent2", "agent3"],
              "kubernetes_node:vars" => {
                kubernetes_role: "node",
                swapfile_path: "/dev/mapper/vagrant--vg-swap_1"
              }
          }
        end
      end
    end
  end
end

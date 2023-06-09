Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo hello"

  config.vm.define "singh" do |singh|
    singh.vm.box = "singh"
  end

  config.vm.define "multn" do |multn|
    multn.vm.box = "multn"
  end
end

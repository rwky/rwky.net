Vagrant.configure("2") do |config|
    config.vm.provider "docker" do |v|
        v.build_dir = "vagrant-provision"
        v.has_ssh = true
        v.remains_running = true
        v.name = 'rwky-net-docker'
        config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    end
    config.ssh.username = "root"
end

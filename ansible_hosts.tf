#-----------------Crete ansible inventory.ini -----------------

resource "local_file" "ansible-inventory" {
  content  = <<-EOT
    [bastion]
    ${yandex_compute_instance.bastion-host.network_interface.0.ip_address} public_ip=${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address} 

    [web]
    ${yandex_compute_instance.web-server1.network_interface.0.ip_address}
    ${yandex_compute_instance.web-server2.network_interface.0.ip_address}

    [prometheus]
    ${yandex_compute_instance.prometheus.network_interface.0.ip_address}

    [grafana]
    ${yandex_compute_instance.grafana.network_interface.0.ip_address} public_ip=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} 

    [elasticsearch]
    ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

    [kibana]
    ${yandex_compute_instance.kibana.network_interface.0.ip_address} public_ip=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} 
    
    [all:vars]
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -p 22 -W %h:%p -q abc@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'
    EOT
  filename = "/home/sav/diplom/ansible/inventory.ini"
}

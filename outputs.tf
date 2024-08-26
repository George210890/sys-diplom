output "bastion-host" {
  value = yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address
}
output "kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
output "grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

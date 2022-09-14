datacenter = "dc1"
server = false
bind_addr = "0.0.0.0"
client_addr = "127.0.0.1"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
cert_file = "/etc/consul.d/certs/dc1-client-consul-0.pem"
key_file = "/etc/consul.d/certs/dc1-client-consul-0-key.pem"
node_name = "Application"
retry_join = ["consul server IP or dns and port"]
ports = {
  https = 8501
  grpc = 8502
}
auto_encrypt = {
  tls = true
}
encrypt= <get from k8s secret - consul-gossip-encryption-key>

$admin_password = 'rajalokan'
$demo_password = $admin_password
$admin_token = '4b46b807-ab35-4a67-9f5f-34bbff2dd439'
$metadata_proxy_shared_secret = '39c24deb-0d57-4184-81da-fc8ede37082e'
$region_name = 'RegionOne'

$cinder_lvm_loopback_device_size_mb = 10 * 1024

$interface = 'eth0'
$ext_bridge_interface = 'br-ex'
$dns_nameservers = ['8.8.8.8', '8.8.4.4']
$private_subnet_cidr = '10.0.0.0/24'
$public_subnet_cidr = '192.168.209.0/24'
$public_subnet_gateway = '192.168.209.2'
$public_subnet_allocation_pools = ['start=192.168.209.30,end=192.168.209.50']

# Note: this is executed on the master
$gateway = generate('/bin/sh',
'-c', '/sbin/ip route show | /bin/grep default | /usr/bin/awk \'{print $3}\'')

$ext_bridge_interface_repl = regsubst($ext_bridge_interface, '-', '_')
$ext_bridge_interface_ip = inline_template(
"<%= scope.lookupvar('::ipaddress_${ext_bridge_interface_repl}') -%>")

if $ext_bridge_interface_ip {
  $local_ip = $ext_bridge_interface_ip
  $local_ip_netmask = inline_template(
"<%= scope.lookupvar('::netmask_${ext_bridge_interface_repl}') -%>")
} else {
  $local_ip = inline_template(
"<%= scope.lookupvar('::ipaddress_${interface}') -%>")
  $local_ip_netmask = inline_template(
"<%= scope.lookupvar('::netmask_${interface}') -%>")
}

$cinder_loopback_base_dir = '/var/lib/cinder'
$cinder_loopback_device_file_name = "${cinder_loopback_base_dir}/\
cinder-volumes.img"
$cinder_lvm_vg = 'cinder-volumes'
$workers = $::processorcount

if !$local_ip {
  fail('$local_ip variable must be set')
}

#notify { "Local IP: ${local_ip}":}
#->
#notify { "Netmask: ${local_ip_netmask}":}
#->
#notify { "Gateway: ${gateway}":}

class { 'apt': }

apt::source { 'ubuntu-cloud':
  location          =>  'http://ubuntu-cloud.archive.canonical.com/ubuntu',
  repos             =>  'main',
  release           =>  'trusty-updates/kilo',
  include           =>  {
    'src'   => false,
  },
  required_packages =>  'ubuntu-cloud-keyring',
}
->
exec { 'apt-update':
    command => '/usr/bin/apt-get update'
}
-> Package <| |>

# Vagrant

Vagrant - building and maintaining virtual software dev environments like virtualbox

Vagrant file to spin up 1 master node and 2 worker nodes. They use the HostOnly Adapter so only the host machine can access those VMs, allowinf the machines to access the internet.


`vagrant ssh k3s-master`
`sudo kubectl get nodes`
`sudo kubectl get pods`

Applies changes:
`vagrant provision`
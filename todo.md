What was wrong and what was fixed:

Problem	Root Cause	Fix
MetalLB speakers crashing	k3s built-in servicelb (klipper-lb) competed for the same ports	Disabled servicelb via /etc/rancher/k3s/config.yaml
All nodes showing 10.0.2.15	k3s was binding to VirtualBox NAT interface instead of host-only	Added --node-ip to server/agent installs
ingress-nginx controller crash loop	Both ingress controllers + port conflict	Removed ingress-nginx; Traefik is already the right choice for k3s
Ingress webhook blocking updates	Stale ingress-nginx-admission ValidatingWebhookConfiguration	Deleted the leftover webhook
Current clean state:

URL	What you get
http://192.168.56.201/	React frontend (via Traefik Ingress)
http://192.168.56.201/api/commitments-one	Spring Boot API (via Traefik Ingress)
http://192.168.56.202:8081/	Mongo Express (direct MetalLB IP)

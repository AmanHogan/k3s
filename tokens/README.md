# tokens/

This folder holds auth tokens for the cluster. Real token files are gitignored — only `.example` files are committed.

| File               | Purpose                  | How to get it                                                                                                                   |
| ------------------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `headlamp.token`   | Headlamp dashboard login | `vagrant ssh k3s-master -c 'kubectl get secret headlamp-token -n kube-system -o jsonpath="{.data.token}" \| base64 -d && echo'` |
| `k3s-server.token` | Worker node join token   | `vagrant ssh k3s-master -c 'sudo cat /var/lib/rancher/k3s/server/node-token'`                                                   |

Copy the `.example` file and fill it in:

```bash
cp tokens/headlamp.token.example tokens/headlamp.token
```

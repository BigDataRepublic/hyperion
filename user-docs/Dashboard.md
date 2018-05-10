# Dashboard
Kubernetes has a fantastic dashboard to monitor your Jobs and Pods.
Before you can use the dashboard, you have to get your dashboard token.
You'll only have to do this once.

Both retrieving your token and viewing the dashboard require you to be connected to the VPN and to have setup your kubectl configuration correctly.

## Getting your dashboard token
1. Run `kubectl get serviceaccounts/dashboard-<user> -o yaml` and replace `<user>` with your user name.
1. Look at the `secrets` tag in the output, there should be only one secret listed with a name like `dashboard-<user>-token-xxxxx`.
1. Run `kubectl describe secrets/dashboard-<user>-token-xxxxx` to retrieve the `token`. Save it somewhere secure so you can easily use it next time you login to the dashboard.

## Viewing the dashboard

1. Run `kubectl proxy` in your terminal
1. In your browser, go to `http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
1. Authenticate using your dashboard token

You will only have access to resources in your own namespace.

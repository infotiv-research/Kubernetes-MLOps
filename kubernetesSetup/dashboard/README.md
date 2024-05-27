# Kubernetes Dashboard

## Setup on the Master Node

To setup the Kubernetes dashboard you can follow the [official documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and this [video tutorial](https://www.youtube.com/watch?v=CICS57XbS9A).

Start the k8s dashboard pods by running:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

Wait and check that the pods have `STATUS >> Running`:

```
kubectl get pods -o wide -n kubernetes-dashboard
```

## Configuration

To configure the Kubernetes dashboard you can follow this [tutrial](https://k21academy.com/docker-kubernetes/kubernetes-dashboard/).

The following command uses a default editor. To ensure that you're using a specific editor, such as `nano`, run:

```
export KUBE_EDITOR=nano
```

To be able to access the dashboard from outside the cluster you need to change the service type :

```
kubectl -n kubernetes-dashboard edit svc kubernetes-dashboard
```

In the file, under `spec`, change the value of `type` variable from `Cluster IP` to `NodePort`.
Also save the number assigned to the `ports: - nodePort ` variable:

```
spec:
  ...

  ports:
  - nodePort: 30964 (example number)

  ...

  type: NodePort
```

You can now access the dashboard in your browser, where you need to enter the IP of the node that is hosting the dashboard pod and the NodePort value from the configuration file:

```
https://<masterIP>:<nodePort>
```

For example:

```
https://master:30964
```

You will get a warning in the browser saying that the connection is insecure. Ignore this, select `Advanced` and `Proceed`.

## Accessing the Dashboard

To be able to login to the dashboard you need to create and apply a ServiceAccount and a ClusterRoleBinding with corresponding Secret.

### Creating the Files

All files can be found in this [repo](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md).

#### ServiceAccount

```
nano serviceAccount.yaml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

#### ClusterRoleBinding

```
nano clusterroleBinding.yaml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

#### Secret

```
nano token.yaml
```

```
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
```

### Applying the Files

To apply the files run:

```
kubectl apply -f serviceAccount.yaml
```

```
kubectl apply -f clusterroleBinding.yaml
```

```
kubectl apply -f token.yaml
```

### Dashboard Menu

The dashboard menu should resemble this:

![Dashboard Menu](resources/dashboard_menu.png)

Now run the below command in the master terminal to get the token (password):

```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

Copy the output and got to your browser. The output is extensive and may look like this, example token:

```
eyJhbGciOiJSUzI1NiIsImtpZCI6Ikhwck5OWFhhRDQtUnR6UG1kTTBldHNCT2ExRkxVZlhfSDBSWVNEUjRSdFkifQ.
eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1
lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm
5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZ
SI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI2
NTYzMjg1YS0zNzFiLTQ0ZjEtYjkwYy1jOWVlZTI3NWRmYzIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3V
iZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.cGMwINZFSoQwS4GDA4lsT9WoDXwl8eP737IcHew_DBo8jSUIU
huQuvRTw9z1PWXRYYciqWmZhPSt-G8a9BhHOCHCHbMxqoXxsARM_0_5SmL0ZyKTVvTHhK_5azGOXysCW-a3rnu8IFKF
6xxjgBwNI0o2hSBYkLVHCDJhu0mspR8L33TKLRUWDzm-Mv84fClkYAP7d7U8tCOs7xs4b0ALiR4l4zBvDQwS1TXqHHq
NJAEwaJuPfLzfN-yQ4nw7y3QvTq5UuZzqnTvgCxZ1E8ej7n4iGIpJfuMJD6cdOIlLYI0C1FuiZBF0flF027UZ0wcLyA
7erFaffJvVr5QQNuKZ-w
```

The button `Token` should be selected, NOT `Kubeconfig`.
Paste what you just copied into the `Enter token*` field and `Sign in`.

### Troubleshooting

#### ERROR: `STATUS >> Pending`

After running `kubectl get pods -o wide -n kubernetes-dashboard` you may be getting the following output:

```
NAME                                         READY   STATUS
dashboard-metrics-scraper-5657497c4c-sbvt6   0/1     Pending
kubernetes-dashboard-78f87ddfc-bpppr         0/1     Pending
```

Check the pod error with:

```
kubectl describe pod <NAME> -n <NAMESPACE>
```

A possible output could be:

```
Warning  FailedScheduling  3m20s  default-scheduler  0/2 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 1 node(s) had untolerated taint {node.kubernetes.io/unreachable: }. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
```

Then, make sure that all the nodes have `STATUS >> Ready` by checking:

```
kubectl get nodes
```

#### ERROR: If you have the Flannel pod network add-on and cannot get the dashboard pods to run

This is a useful [video tutorial](https://www.youtube.com/watch?v=arAnjJNcxHQ).

First run:

```
kubectl get pods --all-namespaces
```

Check the pod error with:

```
kubectl describe pod <NAME> -n <NAMESPACE>
```

If you have errors similar to:
`plugin type="flannel" failed (add): failed to delegate add: failed to set bridge addr: "cni0" already has an IP address different from 10.244.1.1/24`
you should ssh into the node that hosts the pods (check with: `kubectl get pods -o wide -n kubernetes-dashboard`)
and run:

```
sudo ip link delete cni0 type bridge:
```

Wait a few moments and then your pods should be running.

import sys
from kubernetes import client, config

config.load_kube_config()

v1 = client.CoreV1Api()
response = v1.list_namespace()

# for ns in response.items:
#    print(ns)
#    print("\nKubernetes Namespace Name is " + str(ns.metadata.name))

# Or Use following method
namespaces = [item.metadata.name for item in response.items]
print(namespaces)

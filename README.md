* Dependencies: `k3d`, `helm`, and `make`.
* `make up` will create a k3d cluster with three workers, setup ingress and the kubernetes dashboard.

## Useful things
* Images from your local docker installation are not automatially available inside the cluser. Run `k3d image import <local_image_name>` to get them inside.
    * Alternatively, you can `docker tag` and `docker push` them to `registry.127.0.0.1.nip.io:12345`.
* `host.k3d.internal` is the address of the host running docker from inside the cluster.
* If you want to expose services without ingress you should:
    * Set them up as a loadBalancer type service.
    * Run `k3d node edit k3d-k3s-default-serverlb --port-add <host_port>:<cluster_target_port>` to expose the port on the load balancer to the local machine.
* If you need to be able to access the 172.16.0.0/12 from inside your cluster, you will need to change the docker network bridge subnet. Add `"bip": "10.98.0.1/20"` to `~/.docker/daemon.json` and restart docker.
    * docker-compose also sometimes uses this address space too. If images won't pull, try stopping your compositions.

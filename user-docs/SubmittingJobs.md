# Submitting jobs to Kubernetes
This page will guide you through the process of submitting a job to Kubernetes.
Before we start, it's useful to know some of the Kubernetes-related terminology:

* **Container**: a Docker container that executes a single process
* **Pod**: a collection of Docker containers with the same lifecycle. Containers that are killed or have finished will be restarted automatically. This is useful for services that need to be online at all times, but is less useful for e.g. training jobs, that do not need to be restarted after finishing.
* **Job**: a Pod that terminates upon finishing. The solution to run-till-completion workloads.

## Creating a Docker image
The only way of running workloads on the Hyperion cluster is by submitting Docker images.
To create a Docker image for your workload, you can use our template, which includes stuff like TensorFlow and CUDA.
You can also use your own image if you have any custom needs.

If you want to use the template image, you should create a Dockerfile in your project directory as follows:

```
FROM b
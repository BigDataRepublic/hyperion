# Submitting jobs to Kubernetes
This page will guide you through the process of submitting a job to Kubernetes.
We are working on a [project](https://github.com/BigDataRepublic/hyperion-cli) that makes this whole process a lot simpler, but until that is finished you will have to follow this guide.
Before we start, it's useful to know some of the Kubernetes-related terminology:

* **Container**: a Docker container that executes a single process
* **Pod**: a collection of Docker containers with the same lifecycle. Containers that are killed or have finished will be restarted automatically. This is useful for services that need to be online at all times, but is less useful for e.g. training jobs, that do not need to be restarted after finishing.
* **Job**: a Pod that terminates upon finishing. The solution to run-till-completion workloads.

## Creating a project
The only way of running workloads on the Hyperion cluster is by submitting Docker images.
To create a Docker image for your workload, you can use one of the [standard recommended base images](BaseImages.md) or create your own.

If you want to use e.g. the TensorFlow base image, you should create a Dockerfile in your project directory as follows:

```
FROM tensorflow/tensorflow:latest-gpu

COPY ./main.sh
COPY ./model.py

CMD ["bash", "main.sh"]
```

If you need other libraries (such as Keras or PyTorch) you can install them in this Dockerfile by adding a line `RUN pip install keras` or you can use a base image that includes your requirements.
There are a lot of deep learning base images already on GitHub, so there's a good chance you'll find something that fits your needs.

Make sure that the command you run at the end of your Dockerfile terminates and doesn't run forever.

For local development, you can use this Dockerfile to test your project.
Before submitting to Hyperion, make sure it works on your local machine, e.g. by running a single epoch on a subsample of your data.

## Pushing your Docker image
Before Hyperion can run your Docker image you need to push it to our private Docker Registry.

### Docker Registry
To use the Docker Registry, you will need to be connected to the VPN and you will need to have setup the root certificate, as explained in the [previous sections](SetupEnvironment.md).

If you have setup everything correctly, you can tag and push your Docker image like so:

```
docker tag <image_id_or_local_name> 10.8.0.1:30000/<user>/<image_name>:<image_tag>
docker push 10.8.0.1:30000/<user>/<image_name>:<image_tag>
```

You always need the `10.8.0.1:30000` prefix, as that refers to the Docker Registry on the Hyperion machine.
For `<user>` we recommend using your Linux username, which are your initials and last name, in lowercase.
For `<image_name>` you can choose anything you want, such as the project name.
For `<image_tag>` you can choose a versioning scheme, you can use "latest", or leave it out entirely.

Please note that everyone has access to all images in the Docker Registry, as long as you are connected to the VPN.
In the future, this whole process will be more automated through the [hyperion-cli](https://github.com/BigDataRepublic/hyperion-cli).

Images that have not been used for 30 days will be removed automatically from the Registry to save storage space.

## Uploading data to the cluster
Make sure to read [this guide](GettingDataOnCluster.md) on how to get data on the cluster.
Also make sure to remember the path where you store the data (either something like `/home/<user>/<project>` or `/home/<user>/scratch/<project>`).

## Creating a Kubernetes deployment
To submit jobs to Kubernetes, you will need to create a deployment file referring to the image to run, the required resources and the necessary data folders to mount.

An example file is shown below, which you should save as `deployment.yaml`

```
---
apiVersion: batch/v1
kind: Job
metadata:
  name: test-project  # the name of your job
spec:
  template:
    spec:
      volumes:
      - hostPath:
          path: /home/sreitsma  # the folder you want to mount into the container
          type: Directory
        name: host
      containers:
      - name: test-project  # give the image in your job a name, can be anything
        image: 10.8.0.1:30000/<user>/<image_name>:latest  # the path to the image
        command: ["bash run_model.sh"]
        resources:
          limits:
            nvidia.com/gpu: 1  # request a single GPU
            memory: "1536Mi"  # the maximum amount of RAM your application can/will use
            cpu: "1"  # the maximum amount of CPU's your application can/will use
          requests:
            memory: "1024Mi"  # the expected amount of memory that you use
            cpu: "1"  # the expected amount of CPU that you use
        volumeMounts:
        - mountPath: /host  # mount the host folder specified above to /data
          name: host
      restartPolicy: Never
---
```

By default, you request 512 MB of memory and 1 CPU core.
The maximum you can request is 24 GB of memory and 2 CPU cores.
If you need to use more CPU cores, please ask for an increase in your personal limits by sending an email to hyperion@bigdatarepublic.nl.
Note that the amount of CPU cores is not necessarily an integer.
You can also request e.g. 1.5 CPU cores.
To understand the request and limit sections a bit better, have a look at [this blogpost](http://www.noqcks.io/notes/2018/02/03/understanding-kubernetes-resources/).

We recommend setting the requests section to the expected amount of memory you will use.
To determine this, run your application locally and note down approximately how much memory your process is using.
Remember to take some margin (+25%) in your application's memory request.
A good range for the memory limit is your request memory + 25%.
Note however, that you are only guaranteed the memory that is in your *request*.
If you are using more than your request (but less than your limit) your Job will continue unless there is another Job that requires that memory, in which case your Job will be forcefully killed!
For CPU, we recommend using a single core, unless you developed your application to use multithreading/multiprocessing.

The documentation of Kubernetes Jobs can be found [here](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) if you need to create more advanced jobs.

The job can be submitted by doing `kubectl apply -f deployment.yaml`.
You can then monitor your application in the [dashboard](Dashboard.md) or via `kubectl describe jobs/awesome-project-trainer`.
This latter command will give you a Pod name as well, which you can then query using `kubectl describe pods/awesome-project-trainer-xxxxx`

To view the output of your application, it's easiest to use the Dashboard.
Go to Jobs and search the Job that you just created and click the Logs button on the right.
The Dashboard also allows you to easily delete Jobs that you want to have cancelled.

## Termination
It is possible that your Job is terminated before it finishes, for example in the case of power loss.
Whenever your Job is scheduled to be killed, your application will receive a TERM signal.
It is up to you how to handle this.
You can choose not to listen to this TERM signal at all, your application will just be killed after 30 seconds.
However, receiving the TERM signal might be a good idea as it will allow you to cleanup and finish any leftover work, such as saving a serialized model.
30 seconds after receiving the TERM signal the Job will be forcefully killed.

If you're training a big network and you don't really want to write logic for the TERM signal, it's good practice to serialize your model and save it to disk every couple of minutes to reduce the amount of lost work should your Job be killed.

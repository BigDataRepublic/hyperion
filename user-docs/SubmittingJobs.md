# Submitting jobs to Kubernetes
This page will guide you through the process of submitting a job to Kubernetes.
We are working on a [project](https://github.com/BigDataRepublic/hyperion-cli) that makes this whole process a lot simpler, but until that is finished you will have to follow this guide.
Before we start, it's useful to know some of the Kubernetes-related terminology:

* **Container**: a Docker container that executes a single process
* **Pod**: a collection of Docker containers with the same lifecycle. Containers that are killed or have finished will be restarted automatically. This is useful for services that need to be online at all times, but is less useful for e.g. training jobs, that do not need to be restarted after finishing.
* **Job**: a Pod that terminates upon finishing. The solution to run-till-completion workloads.

## Creating a project
The only way of running workloads on the Hyperion cluster is by submitting Docker images.
To create a Docker image for your workload, you can use a recommended base image from TensorFlow, which includes TensorFlow and CUDA or you can use your own image if you have any custom needs.

If you want to use the TensorFlow base image, you should create a Dockerfile in your project directory as follows:

```
FROM tensorflow/tensorflow:latest-gpu

COPY ./model.py
CMD ["python", "model.py"]
```

If you need other libraries (such as Keras or PyTorch) you can install them in this Dockerfile by adding a line `RUN pip install keras` or you can use a base image that includes your requirements.
There are a lot of deep learning base images already on GitHub, so there's a good chance you'll find something that fits your needs.

Make sure that the command you run at the end of your Dockerfile terminates and doesn't run forever.

For local development, you can use this Dockerfile to test your project.
Before submitting to Hyperion, make sure it works on your local machine, e.g. by running a single epoch on a subsample of your data.

## Pushing your Docker image
Before Hyperion can run your Docker image you need to push it to a Docker Registry.
The easiest way to push your image is through a public DockerHub account.
However, you can only do this if your image is truly public, as anyone is able to read its contents.
If your image is of a more private nature, you can push to BDR's AWS Docker Registry.

### AWS Docker Registry
To do this, you will first have create a new AWS Docker Repository.
If you have AWS access you can do this yourself in AWS ECS.
If you do not have AWS access you can request an account through Steven.

To create your repository, you login to AWS and type "ECR" in the search field.
You will right away see a page with all AWS repositories.
Create a new repository with a meaningful name, it's good practice to include your user ID at the start of the repository name.
Note the URL that AWS gives you, you will need it later.

When your AWS repository is created you should login to it.
If you don't have the AWS CLI tool yet, you can install it by doing `pip install awscli` and `aws configure` to enter your credentials.
The credentials you need can be created within AWS as explained on [this documentation page](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

After having installed AWS CLI, run the following command:

```
aws ecr get-login --no-include-email --region eu-west-1
```
and run the command that was given in the output of the console.
For DockerHub, you can authenticate using `docker login`.

If you have trouble creating an AWS Docker Registry you can request one of the administrators (hyperion@bigdatarepublic.nl) to create one for you and guide you through the setup process.

Once you have a repository up and running, you can tag and push your Docker image like so:

```
docker tag <image_id_or_local_name> 0123456789012.dkr.ecr.eu-west-1.amazonaws.com/awesome-project-trainer:latest
docker push 0123456789012.dkr.ecr.eu-west-1.amazonaws.com/awesome-project-trainer:latest
```

We understand that this process is quite cumbersome right now.
In the future, this whole process will be automated through the [hyperion-cli](https://github.com/BigDataRepublic/hyperion-cli).

## Uploading data to the cluster
Make sure to read [this guide](http://github.com/BigDataRepublic/hyperion/blob/master/user-docs/GettingDataOnCluster.md) on how to get data on the cluster.
Also make sure to remember the path where you store the data (either `/home/<user>/<project>` or `/home/<user>/scratch/<project>`).

## Creating a Kubernetes deployment
To submit jobs to Kubernetes, you will need to create a deployment file referring to the image to run, the required resources and the necessary data folders to mount.

An example file is shown below, which you should save as `deployment.yaml`

```
---
apiVersion: batch/v1
kind: Job
metadata:
  name: nvidia-test  # the name of your job
spec:
  template:
    spec:
      volumes:
      - hostPath:
          path: /home/sreitsma/test  # the folder you want to mount into the container
          type: Directory
        name: test
      containers:
      - name: awesome-project-trainer  # give the image in your job a name, can be anything
        image: nvidia/cuda  # the path to the image, can be hosted on DockerHub or on our AWS ECR repositories
        command: ["nvidia-smi"]
        resources:
          limits:
            nvidia.com/gpu: 1  # request a single GPU
            memory: "4096Mi"  # the maximum amount of RAM your application can/will use
            cpu: "2"  # the maximum amount of CPU's your application can/will use
          requests:
            memory: "1024Mi"  # the expected amount of memory that you use
            cpu: "1"  # the expected amount of CPU that you use
        volumeMounts:
        - mountPath: /test  # mount the host folder specified above to /data
          name: test
      restartPolicy: Never
---
```

To understand the request and limit sections of this configuration a bit better, have a look at [this blogpost](http://www.noqcks.io/notes/2018/02/03/understanding-kubernetes-resources/).

The documentation of Kubernetes Jobs can be found [here](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) if you need to create more advanced jobs.

The job can be submitted by doing `kubectl apply -f deployment.yaml`.
You can then monitor your application in the [dashboard](http://github.com/BigDataRepublic/hyperion/blob/master/user-docs/Dashboard.md) or via `kubectl describe jobs/awesome-project-trainer`.
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

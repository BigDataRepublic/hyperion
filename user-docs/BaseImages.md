# Base Docker images

## Barebones CUDA image
Use this image if you want to use the GPU but aren't using any of the major deep learning frameworks like TensorFlow or PyTorch.

`nvidia/cuda`

## TensorFlow image
Use this image if you are using TensorFlow without Keras.

GPU: `tensorflow/tensorflow`

CPU: `tensorflow/tensorflow:latest`

## Keras
GPU: `gw000/keras:2.1.4-py3-tf-gpu`

CPU: `gw000/keras:2.1.4-py3-tf-cpu`

Make sure to checkout https://hub.docker.com/r/gw000/keras/ for the latest version specification.

## PyTorch
`pytorch/pytorch`

## CNTK
`microsoft/cntk`

## Alpine Linux
Great if you want to create your own Docker image.
Alpine Linux is extremely small (only 5MB) and is nice to build upon.

`alpine`

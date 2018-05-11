# Getting data on the cluster
To get data on the cluster you need to connect to the cluster using SFTP.
Make sure you've [set up your SFTP connection](http://github.com/BigDataRepublic/hyperion/blob/master/user-docs/SetupEnvironment.md) and make sure you're connected to the VPN.
Open an SFTP connection and make sure you can see directories like `.ssh` and `keys` in the right hand panel.

## Uploading and downloading data
The directory you see when you connect to the SFTP session is your home folder (`/home/<user>`) and resides on the hard disk of Hyperion.
In this folder you can do whatever you want, and no one else is able to access files that you store here (besides administrators).
We recommend creating subfolders in your home folder per project to keep everything neat and ordered.
The hard disk is limited to 4TB so make sure to regularly clean any files you don't need and don't upload gigantic datasets if you don't need to.

To upload and download files, simply drag them from the left to the right panel for upload and vice versa for downloads.

## Scratch folder
You will also see an additional folder in your home directory, called `scratch`.
Any files placed in this folder will reside on the SSD instead of on the HDD.
We have limited space on our SSD (200GB), so you're not supposed to put your entire ImageNet dataset on here.
However, if you have a lot of small files that you need to access often, it can be very useful to put them on the SSD instead of on the HDD to improve performance.

The scratch directory can be accessed in two ways: `/home/<user>/scratch` and `/scratch/<user>`.

Please note that any file in the `scratch` directory that has not been accessed for 30 days will be deleted automatically.

## Project folders
To make working on a project with multiple people and sharing data more convenient, you can request a *project folder* from the administrators (hyperion@bigdatarepublic.nl).
In your request, please mention the following details:

* The project name (max 16 alphanumeric characters)
* Which users should have access (every user will have read and write access)
* The expected size of the project folder (rough estimate is fine)
* Whether you want it to reside on SSD or HDD

An HDD project folder will reside in `/projects/<project_name>` while an SSD project folder will reside in `/scratch/projects/<project_name>`.
You will need these paths when you start containers.

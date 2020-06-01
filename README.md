# mini-uppmax
A container that has the same operating system, same packages installed, and a copy of the module system (not the actual software though) at UPPMAX. The script `software_packer.sh` can be run at UPPMAX to create a tarball of the software you wish to include in container at build time. If any data needs to be accessed from inside the container it can be mounted at runtime.

**What you get**
* CentOS 7
* All yum packages installed at UPPMAX
* A copy of the module files at UPPMAX (not the programs themselves)
* The option to include any of the installed programs at UPPMAX, requires you to rebuild the image.

**What you don't get**
* Shared libraries, these would bloat the image quite a bit. These are solvable on a case by case basis, more on that further down.

## Use case
This repo was created to make a offline replacement for UPPMAX for courses, in case there is some kind of problem making UPPMAX unusable at the time the course is given. If UPPMAX suddenly disappears we can just tell the students to start up a container and all data and software needed would be included, making it possible to continue the course. This will require us to build our own version of this image where we include the software we want to be installed and to provide any data we want to be accessible to the students.

## How to create a course specific image

### Building off the base image in Dockerhub
The base image will just have the OS and packages of UPPMAX, and the `uppmax` and `bioinfo-tools` module. To include the software you want to have access to you will have to login to UPPMAX and run `software_packer.sh`.

```bash
# run on uppmax
bash software_packer.sh bwa star R GATK
```

This will package everything needed to load these modules into a file called `software.package.tar.gz`.  Download this file to your computer, put it in the `packages` folder and build the Dockerfile in that folder (replace `repo/name:version` with whatever you want to name it on Dockerhub, or remove it to have it untagged).

```bash
# run locally
docker build -t repo/name:version .
```


### Building your own base image
If the base image on Dockerhub is too old for your liking you can rebuild it yourself. Follow the same steps as above, but put the `software.package.tar.gz` you created on UPPMAX in the `base/packages` folder instead. Then build the Dockerfile in the `base` folder.

```bash
cd base
docker build -t repo/name:version .
```

This build will download and install all the yum packages from scratch so the image will be completely up-to-date, but it will take about an hour to build it.

## How to run the image once it is built
This will create a named volume called `offline-uppmax-env-proj` which will be mounted to `/proj` inside the container. All data put in there will persist between restarts of the container, i.e. this is where the students should put their lab work. The data used in the labs are usually so big (10+gb) that it does not make sens to put it inside the image. It's better to download it separately and mount it when starting the container.

**Docker**
```bash
docker run \
-v offline-uppmax-env-proj:/proj \
-v /host/path/to/data:/container/path/to/data \
-it \
repo/name:version

# example
docker run \
-v offline-uppmax-env-proj:/proj \
-v /home/user/ngsintro_data:/sw/courses/ngsintro \
-it \
uppmax/offline-uppmax-env:latest

```

**Singularity**
```bash
todo
```


# Todos
* Test if it works.
* Make a singularity equivalent. Weird that it did not just work to convert it.

# offline-uppmax-env
A container that has the same operating system, same packages installed, and a copy of the module system (not the actual software though) at UPPMAX. The script `software_packer.sh` can be run at UPPMAX to create a tarball of the software you wish to include in container at build time. If any data needs to be accessed from inside the container it can be mounted at runtime.

# TLDR
```bash
## ON UPPMAX
# package the software you want to have in your image
git clone https://github.com/UPPMAX/offline-uppmax-env.git
cd offline-uppmax-env
bash software_packer.sh bwa star samtools

## ON LOCAL COMPUTER
git clone https://github.com/UPPMAX/offline-uppmax-env.git
cd offline-uppmax-env

# download the created software.package.tar.gz to the package/ folder

# using Docker
docker build .
docker run \
-v offline-uppmax-env-proj:/proj \
-v /any/host/data/you/want/access/to:/path/inside/container \
-it \
uppmax/offline-uppmax-env:latest

# using singularity
singularity build offline-uppmax-env.sif Singularity
singularity shell \
-b /host/path/to/persistent/projfolder:/proj \
-b /any/host/data/you/want/access/to:/path/inside/container \
offline-uppmax-env.sif
```

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

This will package everything needed to load these modules into a file called `software.package.tar.gz`.  Download this file to your computer, put it in the `packages` folder and build the Dockerfile in that folder (replace `repo/name:version` with whatever you want to name it on Dockerhub, or remove it to have it untagged). The dockerfile will copy all files in `packages/` and unzip all files named `*.package.tar.gz`, so feel free to put additional files there following this naming pattern.

```bash
# run locally
docker build -t repo/name:version .
```


### Building your own base image
If the base image on Dockerhub is too old for your liking you can rebuild it yourself. Follow the same steps as above, but put the `software.package.tar.gz` you created on UPPMAX in the `base/packages` folder instead. The dockerfile will copy all files in `packages/` and unzip all files named `*.package.tar.gz`, so feel free to put additional files there following this naming pattern. Then build the Dockerfile in the `base` folder.

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

After the container is running it should be just like working on uppmax. `module load` should behave the same way and all modules you packed with `software_packer.sh` should be available.

**Singularity**
To get the module system to work in Singularity you have to build the Singularity file as sudo and everything should work. Package the software you need on UPPMAX like in the Docker approach, put the downloaded tarball in the `packages/` folder just like with Docker, and then build it with Singularity.

Just building from Dockerhub (uppmax/offline-uppmax-env:latest) will give you a container with only the `uppmax` and `bioinfo-tools` in it, and the `module` command will not work since it is a function that is not inherited properly when being converted by Singularity. You can get around this by manually typing `source /etc/bashrc.module_env` every time the container starts.

If you build your own Docker image with the software your want, push it to Dockerhub, and convert it to Singularity, you will still have the problem of the `module` command not working. The solution is the same, manually type `source /etc/bashrc.module_env` when the container starts and it should start working. Building the Singularity file instead will not have this problem.

```bash
# 

```

# Troubleshooting

### Missing shared libraries
Unfortunately I could not find an easy way to automatically pull all the shared libraries needed by programs. I had a problem with STAR, that it needed a newer version of GCC. I could get around it by running `ldd $(which star)` on uppmax and see that the file uses was `/sw/comp/gcc/8.3.0_rackham/lib64/libstdc++.so.6`. I put this file in a tar file,

```bash
tar -chzvf libs.package.tar.gz /sw/comp/gcc/8.3.0_rackham/lib64/libstdc++.so.6  # note the -h option, will dereference symbolic links
```

and put the `libs.package.tar.gz` file in the `packages` folder, build the image, and it worked after that.


# Todos
* Test if it works.

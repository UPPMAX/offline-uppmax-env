FROM uppmax/offline-uppmax-env:latest



# copy the package(s) into the container
COPY packages/ /

# unpack the package(s)
WORKDIR /
USER root
RUN for f in *.package.tar.gz; do tar xzvf "$f"; done

# remove problematic modules
#RUN rm -rf /sw/mf/rackham/compilers/gcc/ /sw/mf/rackham/compilers/pgi

# reset workdir and user
WORKDIR /home/uppmax
USER uppmax

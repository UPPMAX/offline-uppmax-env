FROM uppmax/mini-uppmax:base0.1



# copy the software package into the container
COPY software_package.tar.gz /

# unpack the software package
RUN tar -xzvf /software_package.tar.gz

# remove problematic modules
RUN rm -rf /sw/mf/rackham/compilers/gcc/ /sw/mf/rackham/compilers/pgi

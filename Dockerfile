FROM uppmax/offline-uppmax-env:latest



# copy the package(s) into the container
COPY packages/ /

# unpack the package(s)
WORKDIR /
USER root
RUN for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

# remove problematic modules
#RUN rm -rf /sw/mf/rackham/compilers/gcc/ /sw/mf/rackham/compilers/pgi

# install R packages (OPTIONAL. Load the same R version as you have in your software package)
RUN module load R/4.0.0 ; R -e "install.packages('methods',dependencies=TRUE, repos='http://cran.rstudio.com/')"

# reset workdir and user
WORKDIR /home/uppmax
USER uppmax

FROM uppmax/offline-uppmax-env:latest



# copy the package(s) into the container
COPY packages/ /

# unpack the package(s)
WORKDIR /
USER root
RUN for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

# remove problematic modules
#RUN rm -rf /sw/mf/rackham/compilers/gcc/ /sw/mf/rackham/compilers/pgi

RUN yum -y install libxml2-devel openssl-devel libcurl-devel udunits2-devel openblas-devel.x86_64

# install specific R version (OPTIONAL)
RUN export R_VERSION=4.0.0 ; curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm ; yum -y install R-${R_VERSION}-1-1.x86_64.rpm ; ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R ; ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# install R packages (OPTIONAL. Load the same R version as you have in your software package)
RUN R -e "install.packages(c('BiocManager','ggplot2'), dependencies='Depends', repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(version = '3.11')"
RUN R -e "BiocManager::install(c('DESeq2', 'edgeR', 'goseq', 'GO.db', 'reactome.db', 'org.Mm.eg.db', 'pheatmap'))"

# add a init script for sourcing that will fix PS1 and module environment when running through Singularity
RUN echo "PS1='\[\033[01;34m\][\t] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@fake-uppmax\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '" > /uppmax_init ; echo "source /etc/bashrc.module_env" >> /uppmax_init


# reset workdir and user
WORKDIR /home/uppmax
USER uppmax

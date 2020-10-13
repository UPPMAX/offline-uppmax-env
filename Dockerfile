FROM uppmax/offline-uppmax-env:latest



# copy the package(s) into the container
COPY packages/ /

# unpack the package(s)
WORKDIR /
USER root
RUN for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

# remove problematic modules
#RUN rm -rf /sw/mf/rackham/compilers/gcc/ /sw/mf/rackham/compilers/pgi

# install specific R version (OPTIONAL)
RUN export R_VERSION=4.0.0 ; curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm ; yum -y install R-${R_VERSION}-1-1.x86_64.rpm ; ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R ; ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# install R packages (OPTIONAL. Load the same R version as you have in your software package)
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(version = '3.11')"
RUN R -e "install.packages('DESeq2',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('edgeR',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('goseq',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('GO.db',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reactome.db',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('org.Mm.eg.db',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('pheatmap',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2',dependencies=TRUE, repos='http://cran.rstudio.com/')"

RUN yum -y install libxml2-devel openssl-devel libcurl4-openssl-dev udun1its2-devel

# reset workdir and user
WORKDIR /home/uppmax
USER uppmax

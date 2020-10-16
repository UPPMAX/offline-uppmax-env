Bootstrap: docker
From: uppmax/offline-uppmax-env:latest

%files
    # copy the software package files into the container
    packages/*.package.tar.gz /
    

%post
    for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

    yum -y install libxml2-devel openssl-devel libcurl-devel udunits2-devel openblas-devel.x86_64 mysql-devel postgresql-devel

    # install specific R version (OPTIONAL)
    export R_VERSION=4.0.0 ; curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm ; yum -y install R-${R_VERSION}-1-1.x86_64.rpm ; ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R ; ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

    # install R packages (OPTIONAL. Load the same R version as you have in your software package)
    R -e "install.packages(c('BiocManager','remotes','dplyr','pheatmap','stringr','tidyr'), dependencies=TRUE, repos='http://cran.rstudio.com/', Ncpus=8)"
    R -e "install.packages(c('ggplot2'), dependencies=TRUE, repos='http://cran.rstudio.com/', Ncpus=8)"
    R -e "BiocManager::install(version = '3.11')"
    R -e "BiocManager::install(c('DESeq2','edgeR','goseq','GO.db','org.Mm.eg.db','reactome.db', 'pheatmap'))"

    # add a init script for sourcing that will fix PS1 and module environment when running through Singularity
    echo "PS1='\[\033[01;34m\][\t] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@fake-uppmax\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '" >> /.singularity.d/env/99-module_env.sh ;
    cat /etc/bashrc.module_env >> /.singularity.d/env/99-module_env.sh
    chmod a+x /.singularity.d/env/99-module_env.sh


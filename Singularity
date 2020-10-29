Bootstrap: docker
From: uppmax/offline-uppmax-env:latest

%files
    # copy the software package files into the container
    packages/*.package.tar.gz /
    

%post
    for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

    yum -y install libxml2-devel openssl-devel libcurl-devel udunits2-devel openblas-devel.x86_64 mysql-devel postgresql-devel

    # install specific R version (OPTIONAL)
    #export R_VERSION=4.0.0 ; curl -O https://cdn.rstudio.com/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm ; yum -y install R-${R_VERSION}-1-1.x86_64.rpm ; rm R-${R_VERSION}-1-1.x86_64.rpm ; ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R ; ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

    # mimic load of gcc/9.3.0
    export GCC_ROOT=/sw/comp/gcc/9.3.0_rackham
    export PATH=$GCC_ROOT/bin:$PATH
    export LD_LIBRARY_PATH=$GCC_ROOT/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$GCC_ROOT/lib64:$LD_LIBRARY_PATH
    export LD_RUN_PATH=$GCC_ROOT/lib:$LD_RUN_PATH
    export LD_RUN_PATH=$GCC_ROOT/lib64:$LD_RUN_PATH
    export CC=gcc
    export CXX=g++
    export FC=gfortran
    export F77=gfortran

    # install R packages (OPTIONAL. Load the same R version as you have in your software package)
    /sw/apps/R/x86_64/4.0.0/rackham/bin/R -e ".libPaths(c('/sw/apps/R/x86_64/4.0.0/rackham/lib64/R/library', .libPaths())) ; install.packages(c('BiocManager','remotes','dplyr','pheatmap','stringr','tidyr','ggplot2'), dependencies=TRUE, repos='http://cran.rstudio.com/', Ncpus=8, lib='/sw/apps/R/x86_64/4.0.0/rackham/lib64/R/library')"
    /sw/apps/R/x86_64/4.0.0/rackham/bin/R -e ".libPaths(c('/sw/apps/R/x86_64/4.0.0/rackham/lib64/R/library', .libPaths())) ; BiocManager::install(c('DESeq2','edgeR','goseq','GO.db','org.Mm.eg.db','reactome.db'))"

    # create a dummy reference genome for ngsintro course
    mkdir -p /sw/data/uppnex/reference/Homo_sapiens/hg19/concat_rm/
    echo -e ">Homo_sapiens.GRCh37.57.dna_rm.concat.fa\nATCG" > /sw/data/uppnex/reference/Homo_sapiens/hg19/concat_rm/Homo_sapiens.GRCh37.57.dna_rm.concat.fa

    # add a init script for sourcing that will fix PS1 and module environment when running through Singularity
    echo "PS1='\[\033[01;34m\][\t] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@offline-uppmax\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '" >> /.singularity.d/env/99-module_env.sh ;
    cat /uppmax_init >> /.singularity.d/env/99-module_env.sh
    chmod a+x /.singularity.d/env/99-module_env.sh



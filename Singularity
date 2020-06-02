Bootstrap: docker
From: uppmax/offline-uppmax-env:latest

%files
    # copy the software package files into the container
    packages/*.package.tar.gz /
    

%post
    cat /etc/bashrc.module_env >> /.singularity.d/env/99-module_env.sh
    for f in *.package.tar.gz; do tar xzvf "$f" || echo "No packages to unpack, continuing." ; rm -f "$f"; done

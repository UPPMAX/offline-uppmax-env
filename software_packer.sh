#!/bin/bash

# A utility to package specified software on uppmax to a tarball that can be
# used when building the mini-uppmax Dockerfile to make the software exist
# inside the container.



set -x
set -e

# make the bio modules available
module load bioinfo-tools

# init packing list
package_list="/usr/local/Modules /sw/mf/ "

# process each package
for module in $@
do


    # skip bioinfo-tools
    if [[ $module ==  "bioinfo-tools" ]]
    then
        continue
    fi

    # status message
    echo "Collecting info about $module"

    # get the module file location
    mf_path=$(module show $module 2>&1 | grep "  /sw/mf" | sed 's/.$//') # remove trailing colon

    # get the module version
    module_version=${mf_path##*/} # https://stackoverflow.com/questions/22727107/how-to-find-the-last-field-using-cut

    # get the module install location
    module_path=$(cat $mf_path | grep set | grep "[[:space:]]modroot[[:space:]]" | tr -s "[:blank:]" " " | cut -d " " -f 3 | cut -d '$' -f 1)/$module_version

    # save locations for packing
    package_list+="$module_path "

done

# status message
echo "Compressing modules: $package_list"

# exit

# package the requested modules, skipping any unreadable files
tar --ignore-failed-read -czf software_package.tar.gz $package_list

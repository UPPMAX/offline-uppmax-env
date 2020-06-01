#!/bin/bash

# A utility to package specified software on uppmax to a tarball that can be
# used when building the mini-uppmax Dockerfile to make the software exist
# inside the container.



#set -x
set -e

# make the bio modules available
module load bioinfo-tools

# init packing list
package_list="/usr/local/Modules /usr/share/Modules /usr/share/lmod /etc/lmodrc.lua /sw/mf/rackham/environment/uppmax /sw/mf/rackham/environment/bioinfo-tools /sw/mf/common/environment/uppmax /sw/mf/common/environment/bioinfo-tools"

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
    module_path=$(cat $mf_path | grep set | grep "[[:space:]]modroot[[:space:]]" | tr -s "[:blank:]" " " | cut -d " " -f 3) # break out the mf file path
    
    # remove any lua environmet variable fetching
    if [[ $module_path == *'$env('* ]] 
    then
        # remove lua function call
        module_path=${module_path//env\(/}
        module_path=${module_path//\)/}
    fi

    # remove version placeholders and add the version
    module_path=$(eval "echo $module_path")/$module_version

    # copy the common folders version of the module file if it exists
    common_mf=/sw/mf/common/$(echo $mf_path | cut -d "/" -f 5-)

    # save locations for packing
    package_list+="$mf_path $common_mf $module_path "

done

# status message
echo "Compressing: tar --ignore-failed-read -cvzf software_package.tar.gz $package_list"

# exit

# package the requested modules, skipping any unreadable files
tar --ignore-failed-read -cvzf software_package.tar.gz $package_list

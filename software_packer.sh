#!/bin/bash

# A utility to package specified software on uppmax to a tarball that can be
# used when building the mini-uppmax Dockerfile to make the software exist
# inside the container.



#set -x
set -e

# make the bio modules available
module load bioinfo-tools

echo ""
# init packing list
package_list="/usr/local/Modules /usr/share/Modules /usr/share/lmod /etc/lmodrc.lua /sw/mf/rackham/environment/uppmax /sw/mf/rackham/environment/bioinfo-tools /sw/mf/common/includes/ "

# find module dependencies
mods_to_check=$@
mods_to_package=""

# keep checking as long as there are modules to check
while (( ${#mods_to_check[@]} ))
do

    # check if it is a module name/version or a mf_path:mod_root format.
    # For problematic modules like gcc and others where the modroot in the
    # module file is made up by lua/tcl varaibles it is possible to manually
    # specify the mf_path and mod_root, separated by a :
    if [[ "$module" == *":"* ]]
    then
        # save to package list and move on
        mods_to_package+="$module "
        continue
    fi

	# pop the first element from the array
	mod=${mods_to_check[0]}
	mods_to_check=( "${mods_to_check[@]:1}" )

    # print status
    echo "Fetching module dependencies for $mod"

	for dep_mod in $(module show $mod 2>&1 | grep "load(" | sed "s/load(\"//" | sed "s/..$//")
	do
		mods_to_check+=($dep_mod)

	done

	mods_to_package+="$mod "

done

# process each unique package
for module in $(echo -e "${mods_to_package// /\\n}" | sort -u)
do

    # check if it is a module name/version or a mf_path:mod_root format.
    if [[ "$module" == *":"* ]]
    then

        # split the mf_path from modroot
        split_arr=(${module//:/ })
        mf_path=${split_arr[0]}
        module_path=${split_arr[1]}

        # copy the common folders version of the module file if it exists
        common_mf=/sw/mf/common/$(echo $mf_path | cut -d "/" -f 5-)

        # save locations for packing
        package_list+="$mf_path $common_mf $module_path "

    else




        # skip problematic modules
        if [[ "$module" ==  "bioinfo-tools" ]] || [[ "$module" == "gcc"* ]] || [[ "$module" == "python"* ]]
        then
            echo "Skipping problematic module $module, please add it manually, if it is needed, by specifying the module file path and module root dir separated by a colon instead of the module name. So, not gcc/6.2.0, instead write /sw/mf/rackham/compilers/gcc/6.2.0:/sw/comp/gcc/6.2.0_rackham   Use module show gcc/6.2.0 to see the paths."
            continue
        fi
    
        # status message
        echo "Collecting info about $module"
    
        # get the module file location
        mf_path=$(module show $module 2>&1 | grep "  /sw/mf" | sed 's/.$//') # remove trailing colon
    
        # get the module version
        module_version=${mf_path##*/} # https://stackoverflow.com/questions/22727107/how-to-find-the-last-field-using-cut
    
        # get the module install location
        module_path=$(cat $mf_path | grep set | grep "[[:space:]]modroot[[:space:]]" | tr -s "[:blank:]" " " | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d " " -f 3) # break out the mf file path
        
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
    
    #    # see if any libraries are explicitly stated in the module file
    #    while read -r line ; do
    #        echo "Processing $line"
    #        # your code goes here
    #    done < <(cat $mf_path | grep LD_ | )
    
        # save locations for packing
        package_list+="$mf_path $common_mf $module_path "
    
    fi
done

# status message
echo "Compressing: tar --ignore-failed-read -chvzf software_package.tar.gz $package_list"

# exit

# package the requested modules, skipping any unreadable files
tar --ignore-failed-read -chvzf software.package.tar.gz $package_list

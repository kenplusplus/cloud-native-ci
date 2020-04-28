#!/bin/bash

repo_dir="/workspace/source/repo"
build_root_dir="/workspace/build"
build_path=""
package_category_dirs=(BaseOS AppStream)
package_path=""

#
# Find package in repo with given package name
#
find_package() {
    if [ -z $PACKAGE ]; then
        echo "Please specify the package for build"
        exit 1
    fi

    for i in ${package_category_dirs[@]}; do 
        if [ -d ${repo_dir}/$i/$PACKAGE ]; then
            package_path=${repo_dir}/$i/$PACKAGE
            break
        fi
    done

    if [ -z $package_path ]; then
        echo "Could not find the specific package"
        exit 1
    fi

    echo "Package path: $package_path"
}

#
# Download file from give address and do md5sum
# $1 Downloaded file name 
# $2 Download URL
# $3 md5sum
#
download_file() {
    need_download=1
    if [ -f $1 ]; then
        MD5SUM=$(md5sum "$1" | grep --only-matching -m 1 '^[0-9a-f]*')
        if [ "${MD5SUM}" == "$3" ]; then
            need_download=0
        else
            rm $1
        fi
    fi

    if ((need_download)); then
        wget -O $1 --show-progress $2
        echo "Success download $1"
    fi
    echo "$1 already exists."
}

#
# Download and install upstream RPM into ~/rpmbuild folder
#
download_install_upstream_src() {
    # the first line is source file name
    src_file_name=$(sed '1q;d' $package_path/upstream)
    # the second line is upstream url
    upstream_url=$(sed '2q;d' $package_path/upstream)
    # the third line is md5sum
    md5sum_val=$(sed '3q;d' $package_path/upstream)

    echo "Upstream URL: $upstream_url"
    echo "SRC file name: $src_file_name"
    
    download_file $build_path/$src_file_name $upstream_url $md5sum_val
    mkdir -p $build_path/rpmbuild/SOURCES
    echo "%_topdir $build_path/rpmbuild" > ~/.rpmmacros
    extension="${src_file_name##*.}"
    
    case $extension in
        rpm)
            rpm -i $build_path/$src_file_name
            ;;
        *)
            cp $build_path/$src_file_name $build_path/rpmbuild/SOURCES
            ;;
    esac
}

copy_patches_to_src() {
    cp $package_path/*.patch $build_path/rpmbuild/SOURCES 2>/dev/null
}

#
# Build rpm via mock
#
build_rpm() {
    if ! command -v mock >/dev/null 2>&1; then
        echo "Please install mock for build via 'dnf install epel-release mock'"
        exit 1
    fi

    echo "Build RPM..."
    mock -r intel-linux-centos \
        --resultdir=$build_path/result \
        --rootdir=$build_path/buildroot \
        --no-cleanup-after \
        --enable-plugin=ccache \
        --enable-network \
        --old-chroot \
        --rebuild \
        --spec $package_path/$PACKAGE.spec \
        --source $build_path/rpmbuild/SOURCES
    echo "Complete to build RPM..."
}

find_package
build_path=$build_root_dir/$PACKAGE
mkdir -p $build_path
download_install_upstream_src
copy_patches_to_src
build_rpm

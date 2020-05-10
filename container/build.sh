#!/bin/bash

curr_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))
action="all"
registry=""
container="all"
tag="latest"

function usage {
    cat << EOM
usage: $(basename "$0") [OPTION]...
    -a <build|publish|save|all>  all is default, which not include save. Please execute save explicity if need.
    -r <registry prefix> the prefix string for registry
    -c <pkg|bridge|all> the container to be built and published
    -g <tag> container image tag
EOM
    exit 0
}

function process_args {
    while getopts ":a:r:c:g:h" option; do
        case "${option}" in
            a) action=${OPTARG};;
            r) registry=${OPTARG};;
            c) container=${OPTARG};;
            g) tag=${OPTARG};;
            h) usage;;
        esac
    done

    if [[ "$action" =~ ^(build|publish|save|all) ]]; then
        :
    else
        echo "invalid type: $action"
        usage
    fi

    if [[ "$container" =~ ^(bridge|all) ]]; then
        :
    else
        echo "invalid container name: $container"
        usage
    fi

    if [[ "$registry" == "" ]]; then
        echo "Error: Please specify your docker registry via -r <registry prefix>."
        exit 1
    fi
}

function build_images {
    if [[ "$container" =~ ^(bridge|all) ]]; then
        echo "Build webhook bridge container..."
        cd $curr_dir/webhook-bridge
        sudo -E docker build \
            --no-cache \
            --build-arg http_proxy=$http_proxy \
            --build-arg https_proxy=$https_proxy \
            --build-arg no_proxy=$no_proxy \
            . \
            -t ${registry}/il-webhook-bridge:${tag}
    fi

}

function publish_images {
    if [[ "$container" =~ ^(bridge|all) ]]; then
        echo "Publish webhook-bridge container ..."
        sudo docker push ${registry}/il-webhook-bridge:${tag}
    fi

}

function save_images {
    echo 'Save image to file, please use "gunzip -c mycontainer.tgz | docker load" to restore.'

    if [[ "$container" =~ ^(bridge|all) ]]; then
        echo "Save webhook bridge container ..."
        sudo docker save ${registry}/il-webhook-bridge:${tag} | gzip > ${curr_dir}/${registry}/il-package-builder-${tag}.tgz
    fi

}

process_args "$@"
echo ""
echo "-------------------------"
echo "action: ${action}"
echo "container: ${container}"
echo "tag: ${tag}"
echo "mirror: ${swupd_mirror}"
echo "registry: ${registry}"
echo "-------------------------"
echo ""

if [[ "$action" =~ ^(build|all) ]]; then
    build_images
fi

if [[ "$action" =~ ^(publish|all) ]]; then
    publish_images
fi

if [[ "$action" =~ ^(save) ]]; then
    save_images
fi

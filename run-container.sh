#!/bin/bash
function usage {
  printf "Usage: bash run-container.sh [OPTIONS] \n"
  printf " -h  Display this help message.\n"
  printf " -n  image name\n"
  printf " -t  image tag\n"
  printf " -d  ROS_DOMAIN_ID value\n"
  exit 0
}
while getopts :n:t:d:h opt; do
  case $opt in
    h) usage ;;
    n) NAME=${OPTARG};;
    t) TAG=${OPTARG};;
    d) ROS_DOMAIN_ID=${OPTARG};;
    *) printf "run image: "$1" is not a valid option. \n"
       usage
      exit 1
    esac
done

mkdir -p ros_pkgs

# pkg volume
docker volume create --driver local \
    --opt type="none" \
    --opt device="${PWD}/ros-pkgs/" \
    --opt o="bind" \
    "${NAME}_src_vol"

xhost +
docker run \
    --net=host \
    --ipc=host \
    --env ROS_DOMAIN_ID=${ROS_DOMAIN_ID} \
    --env DISPLAY=${DISPLAY} \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/dev:/dev" \
    --privileged \
    -it \
    --rm \
    --volume="${NAME}_src_vol:/home/ros/ros_ws/src/:rw" \
    "${NAME}:${TAG}"
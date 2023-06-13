ARG BASE_IMAGE=ros
ARG BASE_TAG=foxy-ros-base
ARG ROS_DISTRO=foxy
FROM ${BASE_IMAGE}:${BASE_TAG}

ENV DEBIAN_FRONTEND=noninteractive

# Dependencies

RUN apt-get update

COPY ./apt-requirements.txt /
RUN xargs apt-get install -y </apt-requirements.txt \
&& rm -rf /var/lib/apt/lists/*

ARG PIP_INDEX_URL="https://pypi.org/simple"
ENV PIP_INDEX_URL=${PIP_INDEX_URL}
RUN echo PIP_INDEX_URL=${PIP_INDEX_URL}
COPY ./py-requirements.txt /
RUN python3 -m pip install  -r /py-requirements.txt

# create user
ARG UID=1000
ARG GID=1000
RUN addgroup --gid ${GID} bicar
RUN adduser --gecos "BICAR User" --disabled-password --uid ${UID} --gid ${GID} bicar
RUN usermod -a -G dialout bicar
ADD config/99_aptget /etc/sudoers.d/99_aptget
RUN chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

ENV USER bicar
USER bicar

# create and build ros workspace
ENV HOME /home/${USER} 
RUN mkdir -p ${HOME}/ros_ws/src

WORKDIR ${HOME}/ros_ws
RUN /bin/bash -c "source source /opt/ros/${ROS_DISTRO}/setup.bash; colcon build --symlink-install"


# set up environment
COPY config/update_bashrc /sbin/update_bashrc
RUN sudo chmod +x /sbin/update_bashrc ; sudo chown bicar /sbin/update_bashrc ; sync ; /bin/bash -c /sbin/update_bashrc ; sudo rm /sbin/update_bashrc
# Set entrypoint
COPY config/entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh ; sudo chown bicar /ros_entrypoint.sh ;

# Clean image
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* 
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
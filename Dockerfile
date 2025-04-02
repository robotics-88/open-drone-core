# Has ROS2 libraries and some packages installed
FROM ros:humble-ros-base


# Configuration
ARG USER_NAME=decco
ARG LIVOX_SDK_BUILD_LOCATION=/tmp/livox_sdk
ARG LIVOX_WS=/home/$USER_NAME/livox_ws
ARG LIVOX_LOCATION=$LIVOX_WS/src
ARG DISTAL_WS=/home/$USER_NAME/distal_ws
ARG COLOSSEUM_LOCATION=/home/$USER_NAME/src


# Create new user with sudo permissions
RUN useradd --create-home --shell /bin/bash $USER_NAME && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd


# Install apt dependencies
USER root
RUN apt update && \
    apt install -y ssh-client iputils-ping iproute2 udev unzip bash-completion git-lfs \
        # Needed for Colosseum. TODO: look into removing. Should probly be installed in its setup script
        libunwind-dev &&\
    git lfs install


# Trust github, in order to pull private git sources via ssh key
# USER ${USER_NAME}
# RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts


# Install livox_sdk
USER root
WORKDIR ${LIVOX_SDK_BUILD_LOCATION}
RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git && \
    cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    sudo make install
RUN rm -rf ${LIVOX_SDK_BUILD_LOCATION}


# Install livox_ros_driver2 (All rosdep actions must be done as non-root user, to avoid permissions issues)
USER ${USER_NAME}
WORKDIR ${LIVOX_LOCATION}
RUN . /opt/ros/humble/setup.sh && \
    git clone https://github.com/Livox-SDK/livox_ros_driver2.git && \
    # Livox is non-conforming, so we need this hack to successfully install rosdeps
    cp livox_ros_driver2/package_ROS2.xml livox_ros_driver2/package.xml  && \
    rosdep update && \
    rosdep install --from-paths . -y --ignore-src && \
    cd livox_ros_driver2 && \
    # Use -e and -o pipefail to propogate errors in the build script
    bash -e -o pipefail ./build.sh humble --return-code-on-test-failure


# Install Airlib via Colosseum
# TODO: move to r88_5.2 branch, add libstdc++-12-dev apt dependency 
USER ${USER_NAME}
WORKDIR ${COLOSSEUM_LOCATION}
RUN . /opt/ros/humble/setup.sh && \
    git clone -b feature/ubuntu22 https://github.com/robotics-88/Colosseum.git && \
    cd Colosseum && \
    ./setup.sh && \
    ./build.sh
ENV AIRSIM_DIR "${COLOSSEUM_LOCATION}/Colosseum"


# Set up Clang and CCache. Enable colcon mixins
USER ${USER_NAME}
RUN sudo apt install -y clang lld libomp-dev ccache && \
    mkdir -p ~/.ccache && \
    touch ~/.ccache/ccache.conf && \
    echo "max_size = 10G" >> ~/.ccache/ccache.conf && \
    colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update default


# Install Distal sources
# USER ${USER_NAME}
# WORKDIR ${DISTAL_WS}
# # Clone distal using build-host's ssh keys. Then, clone additional sources
# # TODO: don't use custom branch
# # TODO: this command will be cached, even if the `main` ref changes. Use the experimental ADD command, or add distal as a sub-module of this repository
# RUN --mount=type=ssh,mode=0666 git clone -b feature/compiler_settings git@github.com:robotics-88/distal.git ${DISTAL_WS} &&  \
#     cd ${DISTAL_WS}/src &&               vcs import < unprivileged_developer.repos && \
#     cd ${DISTAL_WS}/src/fast-lio2 &&     git submodule update --init --recursive
    
# # Install distal dependencies
# RUN . ${LIVOX_WS}/install/setup.sh && \
#     sudo apt install -y ${DISTAL_WS}/assets/seekthermal-sdk-dev-4.4.2.20_amd64.deb && \
#     rosdep update && \
#     rosdep install --from-paths . -y --ignore-src && \
#     sudo ${DISTAL_WS}/src/mavros/mavros/scripts/install_geographiclib_datasets.sh

# # Build Distal 
# WORKDIR ${DISTAL_WS}
# RUN . /opt/ros/humble/setup.sh && \
#     . ~/livox_ws/install/setup.sh --extend && \
#     colcon build
    
# # Copy exploration
# RUN unzip ${DISTAL_WS}/assets/explore_uav.zip -d ${DISTAL_WS}/install


# Set up environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source ${LIVOX_WS}/install/setup.bash --extend" >> ~/.bashrc && \
    echo "source ${DISTAL_WS}/install/setup.bash --extend" >> ~/.bashrc

# TODO: still need these?
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
# RUN git config --global core.editor "code --wait"


# TEMP: GET UNREAL
# USER ${USER_NAME}
# WORKDIR /home/${USER_NAME}/Unreal
# ADD Linux_Unreal_Engine_5.5.1.zip .
# RUN unzip Linux_Unreal_Engine_5.5.1.zip -d . && \
#     rm Linux_Unreal_Engine_5.5.1.zip
# RUN sudo apt update && \
#     sudo apt install -y libvulkan-dev xdg-user-dirs xdg-utils


ENV USER=USER_NAME
USER ${USER_NAME}
WORKDIR ${DISTAL_WS}
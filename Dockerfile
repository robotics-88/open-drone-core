FROM osrf/ros:humble-desktop-full

# Deps

RUN sudo apt update
RUN sudo apt install -y ssh-client iputils-ping iproute2

# User stuff
ARG USER_ID
ARG GROUP_ID
ARG USER_NAME
ARG GROUP_NAME

RUN addgroup --gid $GROUP_ID $GROUP_NAME && \
    adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USER_NAME && \
    usermod -aG sudo $USER_NAME && \
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER $USER_NAME

# Update rosdep
RUN rosdep update

# Create /livox_ws workspace
WORKDIR /livox_sdk

# Install livox sdk
RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git && \
    cd Livox-SDK2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    sudo make install

RUN sudo rm -rf /livox_sdk

# Build livox_ros_driver2
WORKDIR /livox_ws
RUN /bin/bash -c " \
    source /opt/ros/humble/setup.bash && \
    mkdir -p src && \
    git clone https://github.com/Livox-SDK/livox_ros_driver2.git src/livox_ros_driver2 && \
    rosdep install --from-paths src -y --ignore-src && \
    cd src/livox_ros_driver2 && \
    ./build.sh humble"

# Install distal deps
COPY ./src/ /setup/src/
WORKDIR /setup/
RUN /bin/bash -c "source /livox_ws/install/setup.bash && \
    rosdep install --from-paths src -y --ignore-src"
RUN /bin/bash -c "sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh"
RUN sudo rm -rf /setup

# Set up environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /distal_ws/install/setup.bash" >> ~/.bashrc
RUN echo "source /livox_ws/install/setup.bash" >> ~/.bashrc
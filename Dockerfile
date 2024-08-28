FROM osrf/ros:humble-desktop-full

# Deps
RUN sudo apt update
# RUN sudo mv /var/lib/dpkg/info/udev.postinst /var/lib/dpkg/info/udev.postinst.backup
RUN sudo apt install -y ssh-client iputils-ping iproute2 udev unzip
# RUN sudo mv /var/lib/dpkg/info/udev.postinst.backup /var/lib/dpkg/info/udev.postinst

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

# Install livox_ros_driver2
WORKDIR /livox_ws
RUN /bin/bash -c " \
    source /opt/ros/humble/setup.bash && \
    mkdir -p src && \
    git clone https://github.com/Livox-SDK/livox_ros_driver2.git src/livox_ros_driver2 && \
    rosdep install --from-paths src -y --ignore-src && \
    cd src/livox_ros_driver2 && \
    ./build.sh humble"

# Update pcl_ros, since its distro release is broken
WORKDIR /pcl_ros_ws/src
RUN git clone https://github.com/ros-perception/perception_pcl.git --branch humble
WORKDIR /pcl_ros_ws
RUN /bin/bash -c " \
    source /opt/ros/humble/setup.bash && \
    rosdep install --from-paths src -y --ignore-src && \
    colcon build"

# Install distal deps
COPY ./src/ /setup/src/
COPY ./assets/ /setup/
WORKDIR /setup/
RUN /bin/bash -c "source /livox_ws/install/setup.bash && \
    rosdep install --from-paths src -y --ignore-src"
RUN /bin/bash -c "sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh"
RUN /bin/bash -c "sudo unzip Seek_Thermal_SDK_4.4.2.20.zip"
RUN /bin/bash -c "sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/lib/libseekcamera.so /usr/local/lib && \
                  sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/lib/libseekcamera.so.4.4 /usr/local/lib && \
                  sudo cp -r Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/include/* /usr/local/include && \
                  sudo cp Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/driver/udev/10-seekthermal.rules /etc/udev/rules.d && \
                  sudo chmod u+x Seek_Thermal_SDK_4.4.2.20/x86_64-linux-gnu/bin/*"

# Remove pcl_ros installation since we are building from source
RUN sudo apt-get remove -y ros-humble-pcl-ros

# Set up environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /distal_ws/install/setup.bash --extend" >> ~/.bashrc
RUN echo "source /livox_ws/install/setup.bash --extend" >> ~/.bashrc
RUN echo "source /pcl_ros_ws/install/setup.bash --extend" >> ~/.bashrc
RUN echo "export AIRSIM_DIR=\"/Colosseum\"" >> ~/.bashrc
RUN echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib" >> ~/.bashrc

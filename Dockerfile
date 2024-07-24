FROM ros:humble-ros-base

RUN sudo apt update
RUN sudo apt install -y ssh-client iputils-ping iproute2 \ 
    python3-vcstool python3-rosinstall-generator python3-osrf-pycommon \ 
    ros-humble-rviz2

RUN mkdir -p /setup/
COPY src/mavros /setup/
WORKDIR /setup/

RUN rosinstall_generator --format repos mavlink | tee /tmp/mavlink.repos
RUN rosdep install --from-paths mavros --ignore-src -y
RUN ./mavros/scripts/install_geographiclib_datasets.sh

# Set up environment
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
RUN echo "source /workspaces/distal/install/setup.bash" >> ~/.bashrc

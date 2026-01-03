FROM osrf/ros:humble-desktop-full

# Deps
RUN apt-get update
RUN apt-get install -y \
    ssh-client \
    iputils-ping \
    iproute2 \
    udev \
    unzip \
    bash-completion \
    git-lfs \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Handle user stuff
ARG USERNAME=developer
ENV USER=$USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# Setup workspace
WORKDIR /open-drone-workspace
ENV WORKSPACE_DIR="/open-drone-workspace"
ENV DRONE_DIR="$WORKSPACE_DIR/open-drone-core"
ENV LIVOX_DIR="$WORKSPACE_DIR/livox_ws"
ENV STEP_DIR="$DRONE_DIR/scripts/steps"
ENV PYTHONNOUSERSITE=1

# Copy source files necessary for drone build
RUN mkdir -p {$DRONE_DIR}/src
COPY ./src ${DRONE_DIR}/src
COPY ./.git ${DRONE_DIR}/.git

RUN sudo chown -R ${USERNAME}:${USERNAME} ${DRONE_DIR}

# Install steps - TODO put all copies as one once working reliably
COPY ./scripts/steps/00-install-deps.sh ${STEP_DIR}/00-install-deps.sh
RUN $STEP_DIR/00-install-deps.sh

COPY ./scripts/steps/01-install-ros.sh ${STEP_DIR}/01-install-ros.sh
RUN $STEP_DIR/01-install-ros.sh --desktop

COPY ./scripts/steps/02-fetch-source.sh ${STEP_DIR}/02-fetch-source.sh
RUN $STEP_DIR/02-fetch-source.sh --full

COPY ./scripts/steps/03-livox-setup.sh ${STEP_DIR}/03-livox-setup.sh
RUN $STEP_DIR/03-livox-setup.sh

COPY ./scripts/steps/04-open-drone-server.sh ${STEP_DIR}/04-open-drone-server.sh
RUN $STEP_DIR/04-open-drone-server.sh

COPY ./scripts/steps/10-install-sims.sh ${STEP_DIR}/10-install-sims.sh
RUN $STEP_DIR/10-install-sims.sh

COPY ./scripts/steps/09-build.sh ${STEP_DIR}/09-build.sh
RUN $STEP_DIR/09-build.sh

COPY ./scripts/steps/11-frontend.sh ${STEP_DIR}/11-frontend.sh
RUN $STEP_DIR/11-frontend.sh



CMD ["sleep", "infinity"]

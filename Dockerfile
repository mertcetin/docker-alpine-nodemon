FROM mhart/alpine-node:7

MAINTAINER Can Kutlu Kinay <me@ckk.im>

WORKDIR /app
VOLUME /app/src

RUN npm install -g nodemon

ONBUILD ARG SSH_PRIVATE_KEY=none
ONBUILD ARG NPM_REGISTRY="https://registry.npmjs.org/"
ONBUILD COPY package.json yarn.lock* /app/

ONBUILD RUN BUILD_TOOLS="make gcc git g++ openssh-client python" && \
    info(){ printf '\n  ==> %s...\n' "$*"; } && \
    # Enable node-gyp builds
    info 'Installing build tools' && \
    apk add --no-cache $BUILD_TOOLS && \
    info 'Configuring git & ssh' && \
    mkdir -m 700 -p ~/.ssh && \
    # This allows install from all hosts
    echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    echo -e "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa && \
    chmod 600 ~/.ssh/id_rsa && \
    info 'Setting custom registry' && \
    npm set registry ${NPM_REGISTRY} && \
    info 'Installing node modules' && \
    npm install && \
    mv node_modules node_modules_new && \
    info 'Cleaning up build tools' && \
    npm cache clean && \
    apk del --purge $BUILD_TOOLS && \
    rm -rf ~/.ssh ~/.node-gyp /tmp/*

ONBUILD COPY . /app/

ONBUILD RUN \
    rm -rf node_modules && \
    mv node_modules_new node_modules

CMD ["nodemon"]

FROM debian:latest

# Installing dependencies
RUN apt update \
    && apt install -y wget unar gcc make procps sudo unzip build-essential gcc-9 g++-9

# Mystic BBS installation
WORKDIR /root
RUN wget http://www.mysticbbs.com/downloads/mys112a48_l64.rar \
    && unar mys112a48_l64.rar \
    && cd mys112a48_l64

# Cryptolib installation (for SSH and SSL capabilities)
WORKDIR /cryptlib
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
RUN wget http://www.mysticbbs.com/downloads/cl345.zip \
    && unzip -ax cl345.zip \
    && make shared \
    && mv libcl.so.3.4.5 /usr/lib/libcl.so

# RUN wget https://cryptlib-release.s3-ap-southeast-1.amazonaws.com/cryptlib346.zip \
#     && unzip -xa cryptlib346.zip \
#     && make shared \
#     && mv libcl.so.3.4.6 /usr/lib/libcl.so

# Copy default mystic installation
COPY ./mystic/ /mystic
COPY ./src /mystic


WORKDIR /mystic
RUN ./upgrade


# Ports Available does not actually open them, but allow you to in docker
# compose or docker run
EXPOSE 23/tcp
EXPOSE 22/tcp
EXPOSE 513/tcp
EXPOSE 21/tcp
EXPOSE 24554/tcp
EXPOSE 119/tcp
EXPOSE 110/tcp
EXPOSE 25/tcp


# Creating a different user with less capabilites than root (for obvious
# security reason)
ARG USERNAME=mystic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && adduser --disabled-password --disabled-login --no-create-home --gid $USER_GID --uid $USER_UID --gecos '' $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:/mystic/mis > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN chown -R mystic:mystic /mystic

RUN chmod 0555 /mystic/boot.sh /mystic/start.sh /mystic/stop.sh


# Cleaning
RUN rm -rf /root/* /cryptlib
RUN apt purge -y wget unar gcc make unzip build-essential gcc-9 g++-9

# Starting
USER $USERNAME
ENTRYPOINT ["/mystic/boot.sh"]
CMD ["mystic"]

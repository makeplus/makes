ARG USER
ARG UID
ARG GID

ENV LANG en_US.UTF-8

RUN set -x \
 && (userdel ubuntu || true) \
 && groupadd -g $GID $USER \
 && useradd -rm \
        -u $UID \
        -g $GID \
        -d /home/$USER \
        -s /bin/bash \
        $USER \
 && adduser $USER sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && groupadd postdrop \
 && useradd postfix \
 && chown -R $UID.$GID /home/$USER \
 && true

USER $USER

RUN echo 'source /etc/bash_completion' >> /home/$USER/.bashrc

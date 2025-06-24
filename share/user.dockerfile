ARG USER
ARG UID
ARG GID

RUN set -x \
 && userdel ubuntu \
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

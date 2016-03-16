FROM gk0909c/ubuntu
MAINTAINER gk0909c@gmail.com

ENV DEBIAN_FRONTEND=noninteractive \
    WORK_HOME=/home/dev \
    RUBY_VERSION=2.3.0
ENV RBENV_HOME ${WORK_HOME}/.rbenv

RUN apt-get update 
RUN apt-get install -y git build-essential libssl-dev zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev && \
    apt-get install -y liblua5.2-dev lua5.2 gettext tcl-dev && \
    apt-get install -y xvfb libxtst6 

# vim
RUN git clone https://github.com/vim/vim.git && \
    cd vim/src && \
    ./configure --with-features=huge --enable-multibyte --enable-rubyinterp --enable-pythoninterp --with-python-config-dir=/usr/lib/python2.7/config \
      --enable-tclinterp --disable-nls --enable-perlinterp --enable-luainterp --enable-gui=gtk2 --enable-cscope --prefix=/usr && \
    make && \
    make install

# ADD USER
RUN useradd -d ${WORK_HOME} -s /bin/bash -m dev && echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dev && \
    chmod 0440 /etc/sudoers.d/dev && \
    chown dev:dev -R ${WORK_HOME}

USER dev

# rbenv
RUN git clone https://github.com/sstephenson/rbenv.git ${RBENV_HOME}
RUN git clone https://github.com/sstephenson/ruby-build.git ${RBENV_HOME}/plugins/ruby-build
RUN sudo ${RBENV_HOME}/plugins/ruby-build/install.sh

# SETTING
RUN echo "export PATH=${WORK_HOME}/.rbenv/bin:$PATH" >> ${WORK_HOME}/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ${WORK_HOME}/.bashrc && \
    echo 'install: --no-document' >> ${WORK_HOME}/.gemrc && \
    echo 'update: --no-document' >> ${WORK_HOME}/.gemrc

# ruby
RUN bash -l -c "${RBENV_HOME}/bin/rbenv install ${RUBY_VERSION}" && \
    bash -l -c "${RBENV_HOME}/bin/rbenv global ${RUBY_VERSION}" && \
    bash -l -c "${RBENV_HOME}/shims/gem install --no-document bundler"

# Extras
USER root

# Extra packages
RUN apt-get install -y bash-completion

# vimrc
COPY .vimrc ${WORK_HOME}/.vimrc
COPY .vimrc_tab ${WORK_HOME}/.vimrc_tab
RUN chown dev:dev ${WORK_HOME}/.vimrc ${WORK_HOME}/.vimrc_tab

# extra settings
USER dev
RUN echo 'export LESSCHARSET=utf-8' >> ${WORK_HOME}/.bashrc && \
    echo 'export TERM=xterm-256color' >> ${WORK_HOME}/.bashrc && \
    echo "alias view='vim -R'" >> ${WORK_HOME}/.bashrc && \
    echo "alias vi='vim'" >> ${WORK_HOME}/.bashrc && \
    git config --global core.editor 'vim -c "set fenc=utf-8"'

RUN mkdir -p ${WORK_HOME}/.vim/bundle && \
    git clone https://github.com/Shougo/neobundle.vim ${WORK_HOME}/.vim/bundle/neobundle.vim && \
    cd ${WORK_HOME}/.vim/bundle/neobundle.vim/bin && ./neoinstall

WORKDIR ${WORK_HOME}


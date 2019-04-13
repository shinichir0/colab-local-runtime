FROM nvidia/cuda:10.0-base
LABEL maintainer="shinichir0 <github@shinichironaito.com>"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
ENV PATH $PYENV_ROOT/shims:$PATH

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean -y

RUN apt-get install -y git
RUN git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc && eval "$(pyenv init -)"

RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

RUN pyenv install 3.7.3 && pyenv global 3.7.3
RUN pip install pipenv
COPY Pipfile ./
COPY Pipfile.lock ./
RUN set -ex && pipenv install --system --dev --skip-lock

RUN apt-get install curl unzip -y
RUN mkdir -p /usr/share/fonts/opentype/noto
RUN curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto
RUN rm NotoSansCJKjp-hinted.zip
RUN apt-get install fontconfig
RUN fc-cache -f

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font*

RUN pip install jupyter_http_over_ws
RUN jupyter contrib nbextension install --user
RUN mkdir -p $(jupyter --data-dir)/nbextensions
RUN git clone https://github.com/lambdalisue/jupyter-vim-binding $(jupyter --data-dir)/nbextensions/vim_binding
RUN jupyter notebook --generate-config
RUN ipython profile create
RUN jt -t onedork -vim -T -N -ofs 11 -f hack -tfs 11 -cellw 75%

COPY .jupyter/nbconfig ${HOME}/.jupyter/nbconfig
COPY .jupyter/jupyter_nbconvert_config.json ${HOME}/.jupyter/jupyter_nbconvert_config.json
COPY .jupyter/jupyter_notebook_config.json ${HOME}/.jupyter/jupyter_notebook_config.json
COPY .jupyter/jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py
RUN cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/exec_lines = \[\]/exec_lines = \['%matplotlib inline'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py

RUN set -ex && mkdir /workspace

WORKDIR /workspace

ENV PYTHONPATH "/workspace"

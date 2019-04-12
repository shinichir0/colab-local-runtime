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
#RUN pip install pipenv
RUN pip install https://download.pytorch.org/whl/cu100/torch-1.0.1.post2-cp37-cp37m-linux_x86_64.whl
RUN pip install torchvision dask matplotlib pillow pandas

RUN apt-get install curl unzip -y
RUN mkdir -p /usr/share/fonts/opentype/noto
RUN curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
RUN unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto
RUN rm NotoSansCJKjp-hinted.zip
RUN apt-get install fontconfig
RUN fc-cache -f

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font*

RUN pip install jupyter_http_over_ws \
  && jupyter serverextension enable --py jupyter_http_over_ws

RUN set -ex && mkdir /workspace

WORKDIR /workspace

#COPY Pipfile ./
#COPY Pipfile.lock ./
#RUN set -ex && pipenv install --deploy --system --dev

ENV PYTHONPATH "/workspace"

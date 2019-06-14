ARG cuda_version="10.0"
FROM nvidia/cuda:${cuda_version}-base
LABEL maintainer="shinn1r0 <github@shinichironaito.com>"

ARG python_version="3.7.3"
ARG nodejs_version="12"
ARG cica_version="v4.1.2"

EXPOSE 8888
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV HOME /root
ENV PATH $HOME/miniconda/bin:$PATH

RUN apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends curl ca-certificates && \
  curl -sL https://deb.nodesource.com/setup_${nodejs_version}.x | bash - && \
  apt-get install -y --no-install-recommends git fontconfig unzip nodejs && \
  curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh && \
  bash ~/miniconda.sh -b -p $HOME/miniconda && \
  export PATH="$HOME/miniconda/bin:$PATH" && \
  . $HOME/miniconda/bin/activate && \
  echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc && \
  mkdir -p /usr/share/fonts/opentype/noto && \
  curl -O https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip && \
  unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/opentype/noto && \
  rm NotoSansCJKjp-hinted.zip && \
  mkdir -p /usr/share/fonts/opentype/cica && \
  curl -LO https://github.com/miiton/Cica/releases/download/${cica_version}/Cica_${cica_version}.zip && \
  unzip Cica_${cica_version}.zip -d /usr/share/fonts/opentype/cica && \
  rm Cica_${cica_version}.zip && \
  fc-cache -f && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get purge -y curl unzip && \
  apt-get autoremove -y && apt-get autoclean -y

RUN conda config --append channels conda-forge && \
  conda config --add channels pytorch && \
  conda install -y python=${python_version} \
  numpy scipy numba pandas dask matplotlib \
  scikit-learn scikit-image bokeh pillow pyspark xlrd sympy \
  ipython ipyparallel ipywidgets ipympl \
  jupyter nbdime nbconvert nbformat jupyter_contrib_nbextensions jupyter_nbextensions_configurator jupyterthemes \
  beautifulsoup4 lxml jinja2 sphinx \
  isort pep8 autopep8 flake8 pyflakes pylint jedi tqdm \
  pytorch torchvision cudatoolkit=${cuda_version} && \
  conda update --all -y && \
  conda clean --all && \
  pip install -U pip kaggle tb-nightly \
  jupyter_http_over_ws && jupyter serverextension enable --py jupyter_http_over_ws && \
  rm -rf ${HOME}/.cache/pip

RUN echo "\nfont.family: Noto Sans CJK JP" >> $(python -c 'import matplotlib as m; print(m.matplotlib_fname())') \
  && rm -f ~/.cache/matplotlib/font* && \
  jupyter contrib nbextension install --user && \
  jupyter nbextensions_configurator enable --user && \
  mkdir -p $(jupyter --data-dir)/nbextensions && \
  git clone https://github.com/lambdalisue/jupyter-vim-binding $(jupyter --data-dir)/nbextensions/vim_binding && \
  jupyter nbextension enable vim_binding/vim_binding && \
  jt -t onedork -vim -T -N -ofs 11 -f hack -tfs 11 -cellw 95% && \
  jupyter notebook --generate-config && \
  ipython profile create && \
  cat ${HOME}/.ipython/profile_default/ipython_config.py | sed -e "s/#c.InteractiveShellApp.exec_lines = \[\]/c.InteractiveShellApp.exec_lines = \['%matplotlib inline', 'from jupyterthemes import jtplot', 'jtplot.style()'\]/g" | tee ${HOME}/.ipython/profile_default/ipython_config.py

COPY .jupyter/jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py

RUN ipcluster nbextension enable && \
  jupyter nbextension enable toggle_all_line_numbers/main && \
  jupyter nbextension enable code_prettify/code_prettify && \
  jupyter nbextension enable code_prettify/isort && \
  jupyter nbextension enable code_prettify/autopep8 && \
  jupyter nbextension enable livemdpreview/livemdpreview && \
  jupyter nbextension enable codefolding/main && \
  jupyter nbextension enable execute_time/ExecuteTime && \
  jupyter nbextension disable hinterland/hinterland && \
  jupyter nbextension enable toc2/main && \
  jupyter nbextension enable varInspector/main && \
  jupyter nbextension enable ruler/main && \
  jupyter nbextension enable latex_envs/latex_envs && \
  jupyter nbextension enable comment-uncomment/main && \
  jupyter nbextension enable scratchpad/main && \
  jupyter nbextension enable gist_it/main && \
  jupyter nbextension enable keyboard_shortcut_editor/main && \
  jupyter nbextension enable hide_input/main && \
  jupyter nbextension enable hide_input_all/main && \
  jupyter nbextension enable table_beautifier/main && \
  jupyter nbextension enable equation-numbering/main && \
  jupyter nbextension enable highlight_selected_word/main && \
  jupyter nbextension enable freeze/main && \
  jupyter nbextension enable snippets/main && \
  jupyter nbextension enable snippets_menu/main && \
  jupyter nbextension enable vim_binding/vim_binding && \
  jupyter serverextension enable --py nbdime && \
  jupyter nbextension install --py nbdime && \
  jupyter nbextension enable --py nbdime && \
  nbdime extensions --enable

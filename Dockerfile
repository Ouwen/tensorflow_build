FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install curl software-properties-common python-software-properties git -y
RUN add-apt-repository ppa:openjdk-r/ppa && apt-get update && apt-get install openjdk-8-jdk -y
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list && curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
RUN apt-get update && sudo apt-get install bazel -y
RUN apt-get upgrade bazel -y
RUN apt-get install python-numpy python-dev python-wheel -y

RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install jupyter
RUN apt-get install python-pip -y

RUN git clone https://github.com/tensorflow/tensorflow.git /src/tensorflow

ENV PYTHON_BIN_PATH=/usr/bin/python
ENV CC_OPT_FLAGS=-march=native
ENV TF_NEED_JEMALLOC=1
ENV TF_NEED_GCP=0
ENV TF_NEED_HDFS=0
ENV TF_ENABLE_XLA=0
ENV TF_NEED_OPENCL=0
ENV TF_NEED_CUDA=0

WORKDIR /src/tensorflow
RUN git checkout r1.1
RUN bash ./configure
RUN bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
RUN pip install /tmp/tensorflow_pkg/tensorflow-1.1.0-cp27-none-linux_x86_64.whl

RUN mkdir /src/notebooks
WORKDIR /src/notebooks
RUN jupyter notebook --allow-root --generate-config
RUN echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py 

CMD jupyter notebook --allow-root


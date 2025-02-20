FROM ubuntu:22.04

# 환경 변수 설정
ENV PYTHON=python3.11
ENV PIP=pip3
ENV DEBIAN_FRONTEND=noninteractive
ENV NLTK_DATA=/home/notebook-user/nltk_data

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-dev \
    python3-pip \
    git \
    openssh-server \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-eng \
    libtesseract-dev \
    fonts-ubuntu \
    fontconfig \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

# pip 패키지 설치
RUN python3 -m pip install --no-cache-dir \
    pillow-heif \
    pdf2image

# Requirements 설정 및 Python 패키지 설치
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/Unstructured-IO/unstructured.git && \
    mv unstructured/requirements /requirements && \
    rm -rf unstructured

# 사용자 설정
RUN useradd -ms /bin/bash notebook-user && \
    mkdir -p /workspace && \
    chown -R notebook-user:notebook-user /workspace

# 작업 디렉토리 및 사용자 전환
WORKDIR /workspace
USER notebook-user

# Python 패키지 설치 및 초기화
RUN ${PIP} install --no-cache-dir --user \
    pytest \
    nltk \
    "unstructured[all]" \
    unstructured-inference \
    && rm -rf /tmp/* ~/.cache/pip \
    && mkdir -p ${NLTK_DATA} \
    && python3 -m nltk.downloader -d ${NLTK_DATA} punkt averaged_perceptron_tagger \
    && python3 -c "from unstructured.partition.model_init import initialize; initialize()" \
    && python3 -c "from unstructured_inference.models.tables import UnstructuredTableTransformerModel; model = UnstructuredTableTransformerModel(); model.initialize('microsoft/table-transformer-structure-recognition')"

CMD ["/bin/bash"]
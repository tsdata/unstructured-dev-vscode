# 기본 이미지 설정
FROM ubuntu:22.04 AS builder

# 환경 변수 설정
ENV PYTHON=python3.11 \
    PIP="python3.11 -m pip" \
    DEBIAN_FRONTEND=noninteractive \
    TESSDATA_PREFIX=/usr/local/share/tessdata \
    NLTK_DATA=/home/notebook-user/nltk_data \
    PATH="/home/notebook-user/.local/bin:${PATH}"

# 시스템 패키지 설치 (단일 레이어로 통합)
RUN apt-get update && apt-get install -y \
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
    pi-heif \ 
    pdf2image \ 
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2

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
    unstructured \
    unstructured-inference \
    && rm -rf /tmp/* ~/.cache/pip \
    && mkdir -p ${NLTK_DATA} \
    && ${PYTHON} -m nltk.downloader -d ${NLTK_DATA} punkt averaged_perceptron_tagger \
    && ${PYTHON} -c "from unstructured.partition.model_init import initialize; initialize()" \
    && ${PYTHON} -c "from unstructured_inference.models.tables import UnstructuredTableTransformerModel; model = UnstructuredTableTransformerModel(); model.initialize('microsoft/table-transformer-structure-recognition')"

CMD ["/bin/bash"]
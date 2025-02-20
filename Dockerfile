FROM ubuntu:22.04 AS base

# Python 및 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    git \
    openssh-server \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 개발 환경을 위한 사용자 생성
RUN useradd -ms /bin/bash notebook-user && \
    mkdir -p /workspace && \
    chown -R notebook-user:notebook-user /workspace

# 작업 디렉토리 설정
WORKDIR /workspace

USER notebook-user

ENV PATH="${PATH}:/home/notebook-user/.local/bin"
ENV NLTK_DATA=/home/notebook-user/nltk_data

# Python 패키지 설치
RUN pip3 install --user \
    pytest \
    nltk \
    unstructured \
    unstructured-inference

# NLTK 데이터 다운로드
RUN mkdir -p ${NLTK_DATA} && \
    python3 -m nltk.downloader -d ${NLTK_DATA} punkt averaged_perceptron_tagger

CMD ["/bin/bash"]
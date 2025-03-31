FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    NLTK_DATA=/home/notebook-user/nltk_data \
    PYTHON=python3.10 \
    VENV_PATH=/home/notebook-user/venv \
    TESSDATA_PREFIX=/usr/local/share/tessdata
ENV PATH="$VENV_PATH/bin:$PATH"

RUN useradd -ms /bin/bash notebook-user && \
    mkdir -p /workspace && \
    chown -R notebook-user:notebook-user /workspace

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3-pip \
    python3.10-venv \
    git \
    build-essential \
    libmagic-dev \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-kor \
    libreoffice \
    pandoc \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libtesseract-dev \
    fonts-ubuntu \
    fontconfig \
    libheif1 \
    && rm -rf /var/lib/apt/lists/*

RUN fc-cache -fv

RUN if [ ! -f /usr/local/share/tessdata/eng.traineddata ]; then \
        if [ -f /usr/share/tesseract-ocr/4.00/tessdata/eng.traineddata ]; then \
            echo "Copying eng.traineddata to /usr/local/share/tessdata" && \
            mkdir -p /usr/local/share/tessdata && \
            cp /usr/share/tesseract-ocr/4.00/tessdata/eng.traineddata /usr/local/share/tessdata/; \
        else \
            echo "Warning: eng.traineddata not found in expected locations." && \
            echo "Please ensure tesseract-ocr-eng is installed correctly."; \
        fi; \
    fi; \
    if [ ! -f /usr/local/share/tessdata/kor.traineddata ]; then \
        if [ -f /usr/share/tesseract-ocr/4.00/tessdata/kor.traineddata ]; then \
            echo "Copying kor.traineddata to /usr/local/share/tessdata" && \
            mkdir -p /usr/local/share/tessdata && \
            cp /usr/share/tesseract-ocr/4.00/tessdata/kor.traineddata /usr/local/share/tessdata/; \
        else \
            echo "Warning: kor.traineddata not found. If Korean OCR is not needed, this can be ignored." && \
            echo "Otherwise, please ensure tesseract-ocr-kor is installed correctly.";\
        fi; \
    fi

WORKDIR /workspace
USER notebook-user

RUN python3.10 -m venv $VENV_PATH

# Copy requirements.txt before changing user
COPY requirements.txt /workspace/
RUN chown notebook-user:notebook-user /workspace/requirements.txt

# unstructured 관련 requirements 파일 가져오기
RUN git clone --depth 1 https://github.com/Unstructured-IO/unstructured.git /tmp/unstructured && \
    mv /tmp/unstructured/requirements /workspace/unstructured_requirements && \
    rm -rf /tmp/unstructured && \
    find unstructured_requirements/ -type f -name "*.txt" -exec cat '{}' ';' > /tmp/unstructured_combined.txt

# requirements 파일 병합 및 중복 제거
RUN sort -u /workspace/requirements.txt /tmp/unstructured_combined.txt > /tmp/final_requirements.txt && \
    echo "onnxruntime==1.19.2" >> /tmp/final_requirements.txt

# 모든 패키지 설치
RUN pip install --no-cache-dir -r /tmp/final_requirements.txt && \
    pip install --no-cache-dir "unstructured[all]" unstructured-inference && \
    rm -rf /tmp/unstructured_combined.txt /tmp/final_requirements.txt unstructured_requirements/

# NLTK 데이터 다운로드
RUN mkdir -p ${NLTK_DATA} && \
    python3 -m nltk.downloader -d ${NLTK_DATA} punkt averaged_perceptron_tagger

CMD ["/bin/bash"]
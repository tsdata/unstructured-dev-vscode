# Unstructured 개발 환경 설정

이 프로젝트는 Docker를 사용하여 Unstructured 라이브러리 개발을 위한 격리된 환경을 제공합니다.

## 주요 특징

- Ubuntu 22.04 기반 개발 환경
- Python 3.10 및 필수 개발 도구 설치
- VS Code Remote Development 지원
- `venv`를 이용한 가상 환경 자동 생성 및 활성화

## 시스템 요구사항

- Docker
- Docker Compose

## 설치 및 실행 방법

1.  저장소 클론:

    ```bash
    git clone git@github.com:tsdata/unstructured-dev-vscode.git
    cd unstructured-dev-vscode
    ```

2.  Docker 컨테이너 빌드 및 실행:

    ```bash
    docker-compose up -d --build
    ```

3.  기존 컨테이너 제거 및 재빌드 (필요한 경우, 변경 사항 적용):

    ```bash
    docker-compose down -v  # 볼륨까지 제거
    docker-compose up -d --build --force-recreate
    ```

## 참고 사항

- 컨테이너 내부의 작업은 `/workspace` 디렉토리에서 이루어집니다. 이 디렉토리는 호스트 머신의 프로젝트 루트 디렉토리와 자동으로 동기화됩니다.

- 컨테이너 접속 문제 발생 시:

  ```bash
  docker-compose logs unstructured-dev
  ```

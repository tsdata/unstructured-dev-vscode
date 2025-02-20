# Unstructured 개발 환경 설정

이 프로젝트는 Docker를 사용하여 Unstructured 라이브러리 개발을 위한 격리된 환경을 제공합니다.

## 주요 특징

- Ubuntu 22.04 기반 개발 환경
- Python 3.11 및 필수 개발 도구 설치
- VS Code Remote Development 완벽 지원
- NLTK 데이터 자동 설치
- Git 설정 동기화

## 시스템 요구사항

- Docker
- Docker Compose
- Visual Studio Code (선택사항)
- Git

## 설치 및 실행 방법

1. 저장소 클론:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Docker 컨테이너 빌드 및 실행:
```bash
docker-compose up -d --build
```

3. 기존 컨테이너 제거 및 재빌드 (필요한 경우):
```bash
docker-compose down
docker system prune -f  # 이전 이미지 제거
docker-compose up -d --build
```

## 공식 이미지 대비 주요 변경사항 (wolfi에서 Ubuntu로 전환)

1. wolfi 대신 Ubuntu 22.04 기반 이미지 사용
   - glibc 기반으로 VS Code 서버와의 호환성 보장
   - 더 넓은 패키지 지원

2. 개발 환경 개선
   - Ubuntu 기본 패키지로 VS Code 서버 요구사항 자동 충족
   - Python 3.11 및 개발 도구 기본 설치
   - Git 설정 자동 동기화

3. 보안 및 사용자 권한
   - 비루트 사용자로 실행
   - 작업 디렉토리 권한 적절히 설정

## VS Code 통합

1. VS Code에서 Remote Development 확장 설치
2. 'Remote-Containers: Attach to Running Container' 명령 실행
3. unstructured-dev 컨테이너 선택

## 문제 해결

컨테이너 접속 문제 발생 시:
```bash
docker-compose logs unstructured-dev
```

## 참고사항

- 컨테이너 내부의 작업은 `/workspace` 디렉토리에서 이루어집니다.
- Git 설정은 호스트 시스템과 자동으로 동기화됩니다.
- NLTK 데이터는 컨테이너 빌드 시 자동으로 설치됩니다.
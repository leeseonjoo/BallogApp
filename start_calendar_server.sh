#!/bin/bash

echo "Ballog Calendar Server 시작 중..."

# 파이썬 가상환경 확인 및 생성
if [ ! -d "venv" ]; then
    echo "가상환경을 생성합니다..."
    python3 -m venv venv
fi

# 가상환경 활성화
source venv/bin/activate

# 필요한 패키지 설치
echo "필요한 패키지를 설치합니다..."
pip install -r requirements.txt

# 서버 실행
echo "서버를 시작합니다..."
python calendar_server.py


# 체인플릭스 변환 서버

## 설치할 파일 다운로드
```sh
$ cd ~
$ git clone https://github.com/jampick-kr/chainflix-converter-update chainflix
```

## 우분투 모듈 설치 및 기초 설정 작업 수행
```sh
$ sudo ./install.sh
$ # 비밀번호 입력
```

## 하드웨어 인식 확인
```sh
# https://en.wikipedia.org/wiki/Nvidia_NVENC
$ lshw -short
```


## gpu 드라이버 재설치 명령어
```sh
$ sudo apt-get --purge remove *nvidia*
$ sudo apt-get install nvidia-driver-470
```

## 런처 실행
```sh
$ ./chainflix
```

## 명령어 종류
- install - 변환서버 필수 모듈 설치
- reinstall - 변환서버 필수 모듈 재설치
- test:type - 변환가능 타입여부 테스트
- test:stress - 변환가능한 최대 수량 체크
- update - 업데이트 수행
- help - 정보 확인
- start - 변환서버 실행
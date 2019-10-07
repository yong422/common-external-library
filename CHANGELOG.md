CHANGELOG
=========

# v1.2.1

- googletest 추가
- ExternalLibraryInstall 에서 libmaxminddb 설치시 리턴되는 라이브러리 변수명 오류 수정 (다른 모듈과의 통일성)

  - Findlibmaxminddb 모듈의 리턴되는 라이브러리 변수명과 동일하도록 수정.

- README example 수정.

# v1.2.0

- mysqlconnectorc++, boost, libiconv 추가

# v1.1.0

- 프로젝트명 변경
- 기존 modules -> cmake_modules 변경
- external project 설치용 함수 추가
- libmysqlclient 추가

# v1.0.0

- 프로젝트별로 구성된 cmake.modules 에 대한 통합 구성
- libcurl, libevent, hiredis, maxminddb, openssl, thrift, libz 추가

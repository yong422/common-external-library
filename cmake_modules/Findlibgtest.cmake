# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libgtest
#
# exports:
#
#
#   libgtest_FOUND : 패키지 검색 성공여부
#   libgtest_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libgtest_LIBRARIES  : 패키지 라이브러리 파일
#

INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

# googletest 의 경우 install prefix 가 없으며 /usr/local 에 기본 설치.
# user 계정으로 개발 진행시 오류가 발생되므로 googletest 의 경우 source directory 에 그대로 빌드하도록 설정
# 따라서 include 와 library 참조 디렉토리를 source directory 기준으로 참조.
SET ( libgtest_SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/gtest/src/gtest )
FIND_PATH ( libgtest_INCLUDE_DIR
            NAMES gtest/gtest.h
            PATHS ${libgtest_SOURCE_DIR}/googletest/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
# Finally the library itself
FIND_LIBRARY ( libgtest_LIBRARY
               NAMES libgtest.a
               PATHS ${libgtest_SOURCE_DIR}/googlemock/gtest NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libgtest DEFAULT_MSG libgtest_LIBRARY libgtest_INCLUDE_DIR )

IF (( ${libgtest_INCLUDE_DIR} STREQUAL "libgtest_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libgtest_LIBRARY} STREQUAL "libgtest_LIBRARY-NOTFOUND" ))
  SET ( libgtest_FOUND no )
ELSE ()
  SET ( libgtest_FOUND yes )
ENDIF ()

IF ( NOT libgtest_FOUND )
  MESSAGE ( "${ColorRed}Not Found googletest${ColorEnd}" )
  SET ( libgtest_LIBRARIES )
  SET ( libgtest_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found googletest${ColorEnd}" )
  SET ( libgtest_LIBRARIES ${libgtest_LIBRARY} )
  SET ( libgtest_INCLUDE_DIRS ${libgtest_INCLUDE_DIR} )
ENDIF ()

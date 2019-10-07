# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libhiredis
#
# exports:
#
#
#   libhiredis_FOUND : 패키지 검색 성공여부
#   libhiredis_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libhiredis_LIBRARIES  : 패키지 라이브러리 파일
#
# hiredis 의 경우 별도의 configure 와 install 을 실행하지 않는다.
# make 실행된 결과만을 사용하므로 헤더와 라이브러리 경로가 build 디렉토리이다.


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libhiredis_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/hiredis/build )

FIND_PATH ( libhiredis_INCLUDE_DIR
            NAMES hiredis/hiredis.h
            PATHS ${libhiredis_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libhiredis_LIBRARY
               NAMES libhiredis.a
               PATHS ${libhiredis_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libhiredis DEFAULT_MSG libhiredis_LIBRARY libhiredis_INCLUDE_DIR )

IF (( ${libhiredis_INCLUDE_DIR} STREQUAL "libhiredis_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libhiredis_LIBRARY} STREQUAL "libhiredis_LIBRARY-NOTFOUND" ))
  SET ( libhiredis_FOUND no )
ELSE ()
  SET ( libhiredis_FOUND yes )
ENDIF ()

IF ( NOT libhiredis_FOUND )
  MESSAGE ( "${ColorRed}Not Found hiredis${ColorEnd}" )
  SET ( libhiredis_LIBRARIES )
  SET ( libhiredis_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found hiredis${ColorEnd}" )
  SET ( libhiredis_LIBRARIES ${libhiredis_LIBRARY} )
  SET ( libhiredis_INCLUDE_DIRS ${libhiredis_INCLUDE_DIR} )
ENDIF ()

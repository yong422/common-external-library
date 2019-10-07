# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libcurl
#
# exports:
#
#
#   libcurl_FOUND : 패키지 검색 성공여부
#   libcurl_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libcurl_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libcurl_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/curl/build )

FIND_PATH ( libcurl_INCLUDE_DIR
            NAMES curl/curl.h
            PATHS ${libcurl_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libcurl_LIBRARY
               NAMES libcurl.a
               PATHS ${libcurl_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libcurl DEFAULT_MSG libcurl_LIBRARY libcurl_INCLUDE_DIR )

IF (( ${libcurl_INCLUDE_DIR} STREQUAL "libcurl_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libcurl_LIBRARY} STREQUAL "libcurl_LIBRARY-NOTFOUND" ))
  SET ( libcurl_FOUND no )
ELSE ()
  SET ( libcurl_FOUND yes )
ENDIF ()

IF ( NOT libcurl_FOUND )
  MESSAGE ( "${ColorRed}Not Found curl${ColorEnd}" )
  SET ( libcurl_LIBRARIES )
  SET ( libcurl_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found curl${ColorEnd}" )
  SET ( libcurl_LIBRARIES ${libcurl_LIBRARY} )
  SET ( libcurl_INCLUDE_DIRS ${libcurl_INCLUDE_DIR} )
ENDIF ()

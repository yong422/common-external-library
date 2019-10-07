# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libmaxminddb
#
# exports:
#
#
#   libmaxminddb_FOUND : 패키지 검색 성공여부
#   libmaxminddb_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libmaxminddb_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libmaxminddb_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb/build )

FIND_PATH ( libmaxminddb_INCLUDE_DIR
            NAMES maxminddb.h
            PATHS ${libmaxminddb_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
# Finally the library itself
FIND_LIBRARY ( libmaxminddb_LIBRARY
               NAMES libmaxminddb.a
               PATHS ${libmaxminddb_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libmaxminddb DEFAULT_MSG libmaxminddb_LIBRARY libmaxminddb_INCLUDE_DIR )

IF (( ${libmaxminddb_INCLUDE_DIR} STREQUAL "libmaxminddb_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libmaxminddb_LIBRARY} STREQUAL "libmaxminddb_LIBRARY-NOTFOUND" ))
  SET ( libmaxminddb_FOUND no )
ELSE ()
  SET ( libmaxminddb_FOUND yes )
ENDIF ()

IF ( NOT libmaxminddb_FOUND )
  MESSAGE ( "${ColorRed}Not Found maxminddb${ColorEnd}" )
  SET ( libmaxminddb_LIBRARIES )
  SET ( libmaxminddb_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found maxminddb${ColorEnd}" )
  SET ( libmaxminddb_LIBRARIES ${libmaxminddb_LIBRARY} )
  SET ( libmaxminddb_INCLUDE_DIRS ${libmaxminddb_INCLUDE_DIR} )
ENDIF ()

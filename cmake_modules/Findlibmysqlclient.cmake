# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libmysqlclient
#
# exports:
#
#
#   libmysqlclient_FOUND : 패키지 검색 성공여부
#   libmysqlclient_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libmysqlclient_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libmysqlclient_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/mysql/build )

FIND_PATH ( libmysqlclient_INCLUDE_DIR
            NAMES mysql.h
            PATHS ${libmysqlclient_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libmysqlclient_LIBRARY
               NAMES libmysqlclient.a
               PATHS ${libmysqlclient_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libmysqlclient DEFAULT_MSG libmysqlclient_LIBRARY libmysqlclient_INCLUDE_DIR )

IF (( ${libmysqlclient_INCLUDE_DIR} STREQUAL "libmysqlclient_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libmysqlclient_LIBRARY} STREQUAL "libmysqlclient_LIBRARY-NOTFOUND" ))
  SET ( libmysqlclient_FOUND no )
ELSE ()
  SET ( libmysqlclient_FOUND yes )
ENDIF ()

IF ( NOT libmysqlclient_FOUND )
  MESSAGE ( "${ColorRed}Not Found mysqlclient${ColorEnd}" )
  SET ( libmysqlclient_LIBRARIES )
  SET ( libmysqlclient_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found mysqlclient${ColorEnd}" )
  SET ( libmysqlclient_LIBRARIES ${libmysqlclient_LIBRARY} )
  SET ( libmysqlclient_INCLUDE_DIRS ${libmysqlclient_INCLUDE_DIR} )
ENDIF ()

# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libmysqlconnector++
#
# exports:
#
#
#   libmysqlconnectorcpp_FOUND : 패키지 검색 성공여부
#   libmysqlconnectorcpp_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libmysqlconnectorcpp_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libmysqlconnectorcpp_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/mysqlconnectorcpp/build )

FIND_PATH ( libmysqlconnectorcpp_INCLUDE_DIR
            NAMES mysqlx/xapi.h
            PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# version 8 미만의 libmysqlcppconn-static 을 검색한다.
# 없을 경우 version 8 이상의 static file 을 검색하여 라이브러리를 추가한다.
FIND_LIBRARY ( libmysqlconnectorcpp_CHECK_LIBRARY 
                NAMES libmysqlcppconn-static.a
                PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/lib64 NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

IF (${libmysqlconnectorcpp_CHECK_LIBRARY} STREQUAL "libmysqlconnectorcpp_CHECK_LIBRARY-NOTFOUND" )
  FIND_PATH ( libmysqlconnectorcpp_INCLUDE_DIR
              NAMES mysqlx/xapi.h
              PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
  FIND_LIBRARY ( libmysqlconnectorcpp_LIBRARY
                NAMES libmysqlcppconn8-static.a
                PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/lib64 NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
ELSE ()
  FIND_PATH ( libmysqlconnectorcpp_INCLUDE_DIR
              NAMES mysql_connection.h
              PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
  FIND_LIBRARY ( libmysqlconnectorcpp_LIBRARY 
                NAMES libmysqlcppconn-static.a
                PATHS ${libmysqlconnectorcpp_INSTALL_PATH}/lib64 NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
ENDIF ()

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libmysqlconnectorcpp DEFAULT_MSG libmysqlconnectorcpp_LIBRARY libmysqlconnectorcpp_INCLUDE_DIR )

IF (( ${libmysqlconnectorcpp_INCLUDE_DIR} STREQUAL "libmysqlconnectorcpp_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libmysqlconnectorcpp_LIBRARY} STREQUAL "libmysqlconnectorcpp_LIBRARY-NOTFOUND" ))
  SET ( libmysqlconnectorcpp_FOUND no )
ELSE ()
  SET ( libmysqlconnectorcpp_FOUND yes )
ENDIF ()

IF ( NOT libmysqlconnectorcpp_FOUND )
  MESSAGE ( "${ColorRed}Not Found mysqlconnectorcpp${ColorEnd}" )
  SET ( libmysqlconnectorcpp_LIBRARIES )
  SET ( libmysqlconnectorcpp_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found mysqlconnectorcpp${ColorEnd}" )
  SET ( libmysqlconnectorcpp_LIBRARIES ${libmysqlconnectorcpp_LIBRARY} )
  SET ( libmysqlconnectorcpp_INCLUDE_DIRS ${libmysqlconnectorcpp_INCLUDE_DIR} )
  SET ( libmysqlconnectorcpp_INCLUDE_DIR ${libmysqlconnectorcpp_INCLUDE_DIR} )
ENDIF ()

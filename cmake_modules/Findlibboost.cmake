# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libboost
#
# exports:
#
#
#   libboost_FOUND : 패키지 검색 성공여부
#   libboost_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libboost_LIBRARIES  : 패키지 라이브러리 디렉토리
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libboost_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/boost/build )

FIND_PATH ( libboost_INCLUDE_DIR
            NAMES boost/version.hpp
            PATHS ${libboost_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_PATH ( libboost_LIBRARIES
               NAMES libboost_system.a
               PATHS ${libboost_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

FIND_PATH ( libboost_BASE_DIR
               NAMES include/boost/version.hpp
               PATHS ${libboost_INSTALL_PATH} NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libboost DEFAULT_MSG libboost_LIBRARIES libboost_INCLUDE_DIR libboost_BASE_DIR )

IF (( ${libboost_INCLUDE_DIR} STREQUAL "libboost_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libboost_LIBRARIES} STREQUAL "libboost_LIBRARIES-NOTFOUND" ))
  SET ( libboost_FOUND no )
ELSE ()
  SET ( libboost_FOUND yes )
ENDIF ()

IF ( NOT libboost_FOUND )
  MESSAGE ( "${ColorRed}Not Found boost${ColorEnd}" )
  SET ( libboost_LIBRARIES )
  SET ( libboost_INCLUDE_DIRS )
  SET ( libboost_BASE_DIR )
ELSE ()
  MESSAGE ( "${ColorGreen}Found boost${ColorEnd}" )
  SET ( libboost_LIBRARIES ${libboost_LIBRARIES} )
  SET ( libboost_INCLUDE_DIRS ${libboost_INCLUDE_DIR} )
  SET ( libboost_BASE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/boost/build )
ENDIF ()

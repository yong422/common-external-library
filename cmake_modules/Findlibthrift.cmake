# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libthrift
#
# exports:
#
#
#   libthrift_FOUND : 패키지 검색 성공여부
#   libthrift_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libthrift_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libthrift_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/thrift/build )

FIND_PATH ( libthrift_INCLUDE_DIR
            NAMES thrift/Thrift.h
            PATHS ${libthrift_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libthrift_LIBRARY
               NAMES libthrift.a
               PATHS ${libthrift_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libthrift DEFAULT_MSG libthrift_LIBRARY libthrift_INCLUDE_DIR )

IF (( ${libthrift_INCLUDE_DIR} STREQUAL "libthrift_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libthrift_LIBRARY} STREQUAL "libthrift_LIBRARY-NOTFOUND" ))
  SET ( libthrift_FOUND no )
ELSE ()
  SET ( libthrift_FOUND yes )
ENDIF ()

IF ( NOT libthrift_FOUND )
  MESSAGE ( "${ColorRed}Not Found thrift${ColorEnd}" )
  SET ( libthrift_LIBRARIES )
  SET ( libthrift_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found thrift${ColorEnd}" )
  SET ( libthrift_LIBRARIES ${libthrift_LIBRARY} )
  SET ( libthrift_INCLUDE_DIRS ${libthrift_INCLUDE_DIR} )
ENDIF ()

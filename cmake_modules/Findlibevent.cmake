# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libevent
#
# exports:
#
#
#   libevent_FOUND : 패키지 검색 성공여부
#   libevent_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libevent_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libevent_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/libevent/build )

FIND_PATH ( libevent_INCLUDE_DIR
            NAMES event2/event.h
            PATHS ${libevent_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libevent_LIBRARY
               NAMES libevent.a
               PATHS ${libevent_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libevent DEFAULT_MSG libevent_LIBRARY libevent_INCLUDE_DIR )

IF (( ${libevent_INCLUDE_DIR} STREQUAL "libevent_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libevent_LIBRARY} STREQUAL "libevent_LIBRARY-NOTFOUND" ))
  SET ( libevent_FOUND no )
ELSE ()
  SET ( libevent_FOUND yes )
ENDIF ()

IF ( NOT libevent_FOUND )
  MESSAGE ( "${ColorRed}Not Found libevent${ColorEnd}" )
  SET ( libevent_LIBRARIES )
  SET ( libevent_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found libevent${ColorEnd}" )
  SET ( libevent_LIBRARIES ${libevent_LIBRARY} )
  SET ( libevent_INCLUDE_DIRS ${libevent_INCLUDE_DIR} )
ENDIF ()

# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libz
#
# exports:
#
#
#   libz_FOUND : 패키지 검색 성공여부
#   libz_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libz_LIBRARIES  : 패키지 라이브러리 파일
#
#
# FIND_PATH or FIND_LIBRARY 사용시 
# 옵션으로 NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH 추가하는 이유는
# 설치되지 않은 경우 기본 경로에서 찾아지는 경우가 있으므로 기본경로는 배제하도록 설정


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libz_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/zlib/build )

FIND_PATH ( libz_INCLUDE_DIR
            NAMES zlib.h
            PATHS ${libz_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_LIBRARY ( libz_LIBRARY
               NAMES libz.a
               PATHS ${libz_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libz DEFAULT_MSG libz_LIBRARY libz_INCLUDE_DIR )

IF (( ${libz_INCLUDE_DIR} STREQUAL "libz_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libz_LIBRARY} STREQUAL "libz_LIBRARY-NOTFOUND" ))
  SET ( libz_FOUND no )
ELSE ()
  SET ( libz_FOUND yes )
ENDIF ()

IF ( NOT libz_FOUND )
  MESSAGE ( "${ColorRed}Not Found zlib${ColorEnd}" )
  SET ( libz_LIBRARIES )
  SET ( libz_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found zlib${ColorEnd}" )
  SET ( libz_LIBRARIES ${libz_LIBRARY} )
  SET ( libz_INCLUDE_DIRS ${libz_INCLUDE_DIR} )
ENDIF ()

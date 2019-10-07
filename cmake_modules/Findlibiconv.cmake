# External FIND_PACKAGE 사용을 위한 find cmake 파일
#
# find libiconv
#
# exports:
#
#
#   libiconv_FOUND : 패키지 검색 성공여부
#   libiconv_INCLUDE_DIRS : 패키지 헤더 디렉토리
#   libiconv_LIBRARIES  : 패키지 라이브러리 파일
#


INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libiconv_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/iconv/build )

FIND_PATH ( libiconv_INCLUDE_DIR
            NAMES iconv.h
            PATHS ${libiconv_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# Finally the library itself
FIND_PATH ( libiconv_LIBRARIES
               NAMES libiconv.so
               PATHS ${libiconv_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

# 패키지 검색 핸들러를 설정
# ARGS 검색된 내용에 대해서 성공, 실패여부를 cmake default message 로 출력한다.
FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libiconv DEFAULT_MSG libiconv_LIBRARIES libiconv_INCLUDE_DIR )

IF (( ${libiconv_INCLUDE_DIR} STREQUAL "libiconv_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libiconv_LIBRARIES} STREQUAL "libiconv_LIBRARIES-NOTFOUND" ))
  SET ( libiconv_FOUND no )
ELSE ()
  SET ( libiconv_FOUND yes )
ENDIF ()

IF ( NOT libiconv_FOUND )
  MESSAGE ( "${ColorRed}Not Found iconv${ColorEnd}" )
  SET ( libiconv_LIBRARIES )
  SET ( libiconv_INCLUDE_DIRS )
ELSE ()
  MESSAGE ( "${ColorGreen}Found iconv${ColorEnd}" )
  SET ( libiconv_LIBRARIES ${libiconv_LIBRARY} )
  SET ( libiconv_INCLUDE_DIRS ${libiconv_INCLUDE_DIR} )
ENDIF ()

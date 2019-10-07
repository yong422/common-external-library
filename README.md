cmake common
============

cmake build 에 사용되는 공통 모듈 프로젝트     
기타 cmake 관련하여 통합이 가능한 파일들에 대하여 해당 프로젝트에 추가.   
CMAKE version minumum 3.4 를 기준으로 작성.   

# cmake_modules

modules 를 이용하여 외부 라이브러리를 ExternalProject 로 설치하기 위한 cmake 파일 프로젝트


## example

- FIND_PACKAGE 사용을 위한 모듈 작성 [참조](https://gitlab.kitware.com/cmake/community/wikis/doc/tutorials/How-To-Find-Libraries)   
- `cmake_modules/Findlibexample.cmake` 파일을 작성하여 FIND_PACKAGE external project 로 추가하기 위한 라이브러리의 find_external project 를 추가하기 위한 작성방법은 다음과 같다.

  - 상세한 작성법은 `cmake_modules` 내 다른 모듈참조.

  ```cmake
  # FIND_PACKAGE libexample (file : Findlibexample.cmake)
  # exports
  #   libexample_FOUND : 패키지 검색 여부
  #   libexample_INCLUDE_DIRS : 패키지 헤더 디렉토리
  #   libexample_LIBRARIES : 패키지 러이브러리

  # 작성에 필요한 헤더 포함
  INCLUDE ( FindPkgConfig )
  INCLUDE ( FindPackageHandleStandardArgs )
  #
  # 설치 경로는 ExternalLibraryInstall.cmake 파일의 설치함수에서 사용하는 경로와 맞춰야 한다.
  # 상세한건 해당 파일의 external project 설치 함수 참조.
  SET ( libexample_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/example/build )

  # external project 의 include directory 를 검색한다.
  # 검색이 되지 않을 경우 "libz_INCLUDE_DIR-NOTFOUND" string 이 해당 변수에 저장된다.
  # NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH 옵션의 추가 이유는
  #  다음의 검색에서 지정한 경로 외에는 찾지 않도록 하는 옵션이며, 
  #  해당 경로에 추가된 external project 만 사용하도록 할 경우 다음의 옵션을 추가해야 한다.
  FIND_PATH ( libexample_INCLUDE_DIR
            NAMES example.h
            PATHS ${libexample_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
  # 동일하게 동작한다.
  FIND_LIBRARY ( libexample_LIBRARY
                NAMES libexample.a
                PATHS ${libexample_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

  # 헤더파일과 라이브러리 파일을 찾지 못한 경우 리턴되는 FOUND 변수를 no 처리한다.
  IF (( ${libexample_INCLUDE_DIR} STREQUAL "libexample_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libexample_LIBRARY} STREQUAL "libexample_LIBRARY-NOTFOUND" ))
    SET ( libexample_FOUND no )
  ELSE ()
    SET ( libexample_FOUND yes )
  ENDIF ()

  IF ( NOT libexample_FOUND )
    SET ( libexample_LIBRARIES )
    SET ( libexample_INCLUDE_DIRS )
  ELSE ()
    # 헤더와 라이브러리를 찾은 경우 해당 변수에 설정 한후 리턴한다.
    SET ( libexample_LIBRARIES ${libexample_LIBRARY} )
    SET ( libexample_INCLUDE_DIRS ${libexample_INCLUDE_DIR} )
  ENDIF ()
  ```

- Findlibexample.cmake 을 이용한 모듈검색 실패시 설치하기 위한 external project install 함수를 ExternalLibraryInstall.cmake 파일에 정의한다.
- 상세한 ExternalProject_Add 함수 [참조](https://cmake.org/cmake/help/v3.4/module/ExternalProject.html)

  ```cmake
  # example external project add
  # @function INSTALL_EXTERNAL_PROJECT_EXAMPLE
  # @param  _external_name    externalProject 의 project name
  # @param  _version          download 가 제공되는 버전의 버전정보
  #
  FUNCTION ( INSTALL_EXTERNAL_PROJECT_EXAMPLE _external_name _version )
    IF ( NOT _version )
      MESSAGE ( FATAL_ERROR "example version error")
    ELSE ()
      MESSAGE ( STATUS "Install: example ${_version}")
    ENDIF ()
    ExternalProject_Add (
      ${_external_name}
      # git repo
      GIT_REPOSITORY https://github.com/example/example.git
      GIT_TAG ${_version}
      # 파일을 다운로드 하여 진행하는 경우
      # URL http://example.com/example.zip
      # 다운로드 및 빌드, 설치 경로 설정
      # 설치 경로의 경우 위 샘플의 Findlibexample.cmake 와 동일하게 작성해야 한다.
      PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/example
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/example/src/example
      BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/example/src/example
      INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/example/src/build
      # 기본적으로 configure, make, install 의 동작방식은 cmake 기준으로 동작한다.
      # 추가적인 cmake args 의 경우 별도 추가해야 한다.
      # CMAKE_ARGS -DCMAKE_BUILD_TYPE=Debug 
      # autoconf 로 작성된 external project 를 설치 할 경우 COMMAND 변수에 별도의 실행명령을 추가해야 한다.
      # CONFIGURE_COMMAND ./configure
    )
    ExternalProject_Get_Property ( ${_external_name} source_dir binary_dir )
    SET ( libgtest_LIBRARIES
          "${binary_dir}/googlemock/gtest/libgtest.a" PARENT_SCOPE )
    SET ( libgtest
  ```

- Findlibexample.cmake 와 ExternalLibraryInstall (INSTALL_EXTERNAL_PROJECT_EXAMPLE) 작성 후 사용 예.

  ```cmake
  # common-external-library 를 이용하여 external project 를 사용하기 위해 작성
  # 프로젝트의 CMakeLists.txt 파일에 추가.
  # FIND_PACKAGE, ExternalProject_Add, common-external-library 사용을 위한 경로 추가 및 include 추가.
  SET ( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/common-external-library/cmake_modules/" )
  # module include
  INCLUDE ( ExternalProject )
  INCLUDE ( GNUInstallDirs )
  INCLUDE ( ExternalLibraryInstall )

  ADD_LIBRARY ( libexample STATIC IMPORTED GLOBAL )
  FIND_PACKAGE ( libexample )
  IF ( NOT libexample_FOUND )
    INSTALL_EXTERNAL_PROJECT_EXAMPLE ( libexample_EXTERNAL {설치할 버전 또는 태그명} )
  ELSE ()
    ADD_CUSTOM_TARGET ( libexample_EXTERNAL )
    # 설치 되어있는 경우.
  ENDIF ()
  INCLUDE_DIRECTORIES ( "${libexample_INCLUDE_DIRS}" )
  SET_TARGET_PROPERTIES( libexample
                        PROPERTIES
                        IMPORTED_LOCATION "${libexample_LIBRARIES}" )

  ADD_DEPENDENCIES ( libexample libexample_EXTERNAL )
  ```

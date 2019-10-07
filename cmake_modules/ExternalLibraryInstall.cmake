#
# Copyright (c) 2019, Yongkyu Jo
# All rights reserved.
#
#
# 외부 참조 라이브러리의 ExternalProject 설치를 위한 함수 모음
# modules 디렉토리의 Findlib 모듈과의 연동을 위한 설치 경로 prefix 는 고정으로 한다.
# 추후 확장성을 prefix 를 적용할 수 있도록 추가 할 예정. (Findlib와의 연동이 필요)
#
#
# 2019-07-25
#   - v1.2
#   - gtest, 
#
# 2019-04-15
#   - v1.1
#   - mysqlconnectorc++ 추가
# 2019-02-21
#   - v1
#   - monitoring 에서 사용하는 모든 external project 에 대한 install function 추가
#   - prefix, build, install 의 경로는 project 기준으로 libs/temp/{name} 으로 고정
#   - zlib, thrift, libevent, curl, mysqlclient, maxminddb, hiredis, openssl
#
INCLUDE ( ExternalProject )
INCLUDE ( CheckVersion )


# mysqlclient external project
# mysqlclient 의 경우 cmake 에서 각 minor 버전 별로 최신의 patch version 을 git branch 로 제공한다.
# 단 git 의 mysql 을 clone 할 경우 사이즈가 굉장히 큰 관계로 작업시간이 길게 소요된다.
# cmake 3.4 기준 external project 에서 git 을 clone 하게 되어있어 사용하지 않도록 한다.
# 추후, external project 에서 특정 branch 의 export 가 가능 한 경우 git 으로 사용한다.
# branch download 의 경우 github 서버의 다운로드 속도가 빠르지않으므로 mysql 의 download 를 사용한다.
#
# @function INSTALL_EXTERNAL_PROJECT_MYSQL_CLIENT
# @param  _external_name    externalProject 의 project name
# @param  _version          download 가 제공되는 버전의 버전정보
#                           2019-02-21 기준
#                           5.7.25, 5.6.43, 5.5.62
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_MYSQL_CLIENT _external_name _version )
  GET_VERSION_NUMBER ( "MAJOR" ${_version} MYSQL_MAJOR_VERSION )
  GET_VERSION_NUMBER ( "MINOR" ${_version} MYSQL_MINOR_VERSION )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "mysql version error")
  ELSE ()
    MESSAGE ( STATUS "Install: mysql ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    URL https://cdn.mysql.com//Downloads/MySQL-${MYSQL_MAJOR_VERSION}.${MYSQL_MINOR_VERSION}/mysql-${_version}.tar.gz
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/mysql
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysql/src/mysql
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysql/src/mysql
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysql/build
    CMAKE_ARGS -DWITH_EXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITHOUT_SERVER=ON -DWITHOUT_UNITTEST=ON -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    BUILD_COMMAND make
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libmysqlclient_LIBRARIES
        "${install_dir}/lib/libmysqlclient.a" PARENT_SCOPE )
  SET ( libmysqlclient_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# thrift external project
#
# @function INSTALL_EXTERNAL_PROJECT_THRIFT
# @param  _external_name          externalProject 의 project name
# @param  _version                ex) 0.11.0 (tag name)
# @param  _libevent_include_dirs  libevent 의 header path
# @param  _libevent_libraries     libevent 의 library
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_THRIFT _external_name _version _libevent_include_dirs _libevent_libraries )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "thrift version error")
  ELSE ()
    MESSAGE ( STATUS "Install: thrift ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/apache/thrift.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/thrift
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/thrift/src/thrift
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/thrift/src/thrift
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/thrift/build
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DWITH_LIBEVENT=ON -DLIBEVENT_INCLUDE_DIRS=${_libevent_include_dirs} -DLIBEVENT_LIBRARIES=${_libevent_libraries}
    BUILD_COMMAND make
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libthrift_LIBRARIES
        "${install_dir}/lib/libthrift.a" PARENT_SCOPE )
  SET ( libthrift_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# libevent external project
#
# @function INSTALL_EXTERNAL_PROJECT_LIBEVENT
# @param  _external_name    externalProject 의 project name
# @param  _version          ex) release-2.1.8-stable (tag name)
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_LIBEVENT _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "libevent version error")
  ELSE ()
    MESSAGE ( STATUS "Install: libevent ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/libevent/libevent.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/libevent
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/libevent/build
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DCMAKE_C_FLAGS=-fPIC
    LOG_DOWNLOAD TRUE
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libevent_LIBRARIES
        "${install_dir}/lib/libevent.a" PARENT_SCOPE )
  SET ( libevent_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# libcurl external project
#
# @function INSTALL_EXTERNAL_PROJECT_LIBCURL
# @param  _external_name      externalProject 의 project name
# @param  _version            ex) 7.61.1 (version)
# @param  _openssl_root_dir   curl 의 https 기능추가를 위해 빌드에 포함할 openssl dir
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_LIBCURL _external_name _version _openssl_root_dir )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "libcurl version error")
  ELSE ()
    MESSAGE ( STATUS "Install: libcurl ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    URL http://monrepo.gabia.com/repo/src/curl-${_version}.zip
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/curl
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/curl/src/curl
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/curl/src/curl
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/curl/build
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-ssl=${_openssl_root_dir} --disable-ldap
    BUILD_COMMAND make
  )
  ExternalProject_Add_Step ( 
    ${_external_name}
    export_variables
    COMMAND export CFLAGS=-fPIC
    DEPENDERS configure
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/libs/temp/curl/src/curl
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libcurl_LIBRARIES
        "${install_dir}/lib/libcurl.a" PARENT_SCOPE )
  SET ( libcurl_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# hiredis external project
#
# @function INSTALL_EXTERNAL_PROJECT_HIREDIS
# @param  _external_name    externalProject 의 project name
# @param  _version          ex) v0.14.0 (tag name)
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_HIREDIS _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "hiredis version error")
  ELSE ()
    MESSAGE ( STATUS "Install: hiredis ${_version}")
  ENDIF ()
  ExternalProject_Add(
    ${_external_name}
    GIT_REPOSITORY https://github.com/redis/hiredis.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/hiredis
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/hiredis/src/hiredis
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/hiredis/src/hiredis
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/hiredis/build
    CONFIGURE_COMMAND ""  # configure 실행 하지 않음.
    BUILD_COMMAND make
    INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libhiredis_LIBRARIES
        "${install_dir}/lib/libhiredis.a" PARENT_SCOPE )
  SET ( libhiredis_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# openssl external project
#
# @function INSTALL_EXTERNAL_PROJECT_OPENSSL
# @param  _external_name        externalProject 의 project name
# @param  _version              OpenSSL_1_0_2p (tag name)
# @param  _depends_zlib_name    openssl external 이 종속된 zlib external name
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_OPENSSL _external_name _version _depends_zlib_name )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "openssl version error")
  ELSE ()
    MESSAGE ( STATUS "Install: openssl ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/openssl/openssl.git
    GIT_TAG ${_version}
    DEPENDS ${_depends_zlib_name}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/openssl
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/openssl/src/openssl
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/openssl/src/openssl
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/openssl/build
    CONFIGURE_COMMAND ./config --prefix=<INSTALL_DIR> shared zlib
    BUILD_COMMAND make
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libopenssl_ssl_LIBRARY "${install_dir}/lib/libssl.a" PARENT_SCOPE )
  SET ( libopenssl_crypto_LIBRARY "${install_dir}/lib/libcrypto.a" PARENT_SCOPE )
  SET ( libopenssl_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# zlib external project
#
# @function INSTALL_EXTERNAL_PROJECT_ZLIB
# @param  _external_name    externalProject 의 project name
# @param  _version          ex) v1.2.11 (tag name)
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_ZLIB _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "zlib version error")
  ELSE ()
    MESSAGE ( STATUS "Install: zlib ${_version}")
  ENDIF ()  
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/madler/zlib.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/zlib
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/zlib/build
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libz_LIBRARIES
        "${install_dir}/lib/libz.a" PARENT_SCOPE )
  SET ( libz_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
  ENDFUNCTION ()

# maxminddb external project
#
# @function INSTALL_EXTERNAL_PROJECT_MAXMINDDB
# @param  _external_name  externalProject 의 project name
# @param  _version        ex) 1.3.2 (tag name)
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_MAXMINDDB _external_name _version )
  IF ( NOT _version )   
    MESSAGE ( FATAL_ERROR "maxminddb version error")
  ELSE ()
    MESSAGE ( STATUS "Install: maxminddb ${_version}")
  ENDIF ()  
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/maxmind/libmaxminddb.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb/src/maxminddb
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb/src/maxminddb
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb/build
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
    BUILD_COMMAND make
  )
  # build 준비를 위한 bootstrap 스크립트 실행 스텝 추가
  ExternalProject_Add_Step (
    ${_external_name}
    bootstrap
    COMMAND ./bootstrap
    DEPENDEES download
    DEPENDERS configure
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/libs/temp/maxminddb/src/maxminddb
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libmaxminddb_LIBRARIES
        "${install_dir}/lib/libmaxminddb.a" PARENT_SCOPE )
  SET ( libmaxminddb_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# @function INSTALL_EXTERNAL_PROJECT_MYSQL_CONNECTOR_CPP
# @param  _external_name    externalProject 의 project name
# @param  _version          download 가 제공되는 버전의 버전정보
# @param  _depends_path     v8 의 경우 boost 의 경로, v1 의 경우 mysql include 의 경로
#
#                           8.0 version 의 경우 mysql 5.5 부터 지원.
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_MYSQL_CONNECTOR_CPP _external_name _version _depends_path )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "mysql-connector-cpp version error")
  ELSE ()
    MESSAGE ( STATUS "Install: mysql-connector-cpp ${_version}")
  ENDIF ()
  GET_VERSION_NUMBER ( "MAJOR" ${_version} MYSQL_CONNECTOR_MAJOR_VERSION )
  IF ( MYSQL_CONNECTOR_MAJOR_VERSION GREATER 7 )
    SET ( MYSQL_CONNECTOR_LIBRARY_NAME "libmysqlcppconn8-static.a")
    SET ( MYSQL_CONNECTOR_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DWITH_BOOST=${_depends_path} -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC=ON )
  ELSE ()
    # 옵션참조
    # https://dev.mysql.com/doc/connector-cpp/1.1/en/connector-cpp-source-configuration-options.html
    SET ( MYSQL_CONNECTOR_LIBRARY_NAME "libmysqlcppconn-static.a")
    SET ( MYSQL_CONNECTOR_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DMYSQL_DIR=${_depends_path} -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC=ON -DCMAKE_ENABLE_C++11=ON )
  ENDIF ()
  ExternalProject_Add (
      ${_external_name}
      GIT_REPOSITORY https://github.com/mysql/mysql-connector-cpp.git
      GIT_TAG ${_version}
      PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/mysqlconnectorcpp
      BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysqlconnectorcpp/src/mysqlconnectorcpp
      SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysqlconnectorcpp/src/mysqlconnectorcpp
      INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/mysqlconnectorcpp/build
      CMAKE_ARGS ${MYSQL_CONNECTOR_CMAKE_ARGS}
      BUILD_COMMAND make
    )
  ExternalProject_Get_Property ( ${_external_name} install_dir )

  SET ( libmysqlconnectorcpp_LIBRARIES
        "${install_dir}/lib64/${MYSQL_CONNECTOR_LIBRARY_NAME}" PARENT_SCOPE )
  SET ( libmysqlconnectorcpp_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# @function INSTALL_EXTERNAL_PROJECT_BOOST
# @param  _external_name    externalProject 의 project name
# @param  _version          download 가 제공되는 버전의 버전정보
#
#                           1.70.0 형식의 버전
# @memo
#         mysqlconnectorc++ 에서 codecvt 사용을 위해서 boost 사용
#         c++11 에서 std::codecvt 를 지원한다고 표시하나 gcc 기준으로 version 5 이상에서 사용가능
#         std::codecvt 를 사용하지 못할 경우 boost 를 검색하므로 boost locale 설치 필요
#         
#         각 모듈별로 개별 분리되어있으나 빌드의 경우 boost 전체 프로젝트를 받아서 필요 라이브러리 빌드
#         TODO: 이후 git 으로 연동하도록 변경
#               boost base project clone 후 사용할 라이브러리 빌드에 필요한 서브모듈만 추가하여 사용
#               1차적으로 현재 사용하지않음으로 작업하지않으며 mysqlconnectorc++ v8 사용시 적용할 예정
#               git submodule update --init --recursive -- libs/system
#               git submodule update --init --recursive -- libs/locale
#               git submodule update --init --recursive -- libs/headers
#               git submodule update --init --recursive -- tools
#

FUNCTION ( INSTALL_EXTERNAL_PROJECT_BOOST _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "boost version error")
  ELSE ()
    MESSAGE ( STATUS "Install: boost ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    GIT_TAG ${_version}
    GIT_SUBMODULES libs/system libs/locale libs/headers libs/config tools
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/boost
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/boost/src/boost
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/boost/src/boost
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/boost/build
    CONFIGURE_COMMAND ./bootstrap.sh
    BUILD_COMMAND ./b2 install --with-locale --prefix=<INSTALL_DIR> --runtime-link=static
    INSTALL_COMMAND ""
  )

  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libboost_LIBRARIES
        "${install_dir}/lib" PARENT_SCOPE )
  SET ( libboost_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# GNU iconv
# @function INSTALL_EXTERNAL_PROJECT_ICONV
# @param  _external_name    externalProject 의 project name
# @param  _version          download 가 제공되는 버전의 버전정보
#
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_ICONV _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "iconv version error")
  ELSE ()
    MESSAGE ( STATUS "Install: iconv ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    URL https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${_version}.tar.gz
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/iconv
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/iconv/src/iconv
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/iconv/src/iconv
    INSTALL_DIR ${PROJECT_SOURCE_DIR}/libs/temp/iconv/build
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-static
    BUILD_COMMAND make
  )
  ExternalProject_Get_Property ( ${_external_name} install_dir )
  SET ( libiconv_LIBRARIES
        "${install_dir}/lib" PARENT_SCOPE )
  SET ( libiconv_INCLUDE_DIRS "${install_dir}/include" PARENT_SCOPE )
ENDFUNCTION ()

# googletest
# @function INSTALL_EXTERNAL_PROJECT_GOOGLETEST
# @param  _external_name    externalProject 의 project name
# @param  _version          download 가 제공되는 버전의 버전정보
#
#
FUNCTION ( INSTALL_EXTERNAL_PROJECT_GOOGLETEST _external_name _version )
  IF ( NOT _version )
    MESSAGE ( FATAL_ERROR "googletest version error")
  ELSE ()
    MESSAGE ( STATUS "Install: googletest ${_version}")
  ENDIF ()
  ExternalProject_Add (
    ${_external_name}
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG ${_version}
    PREFIX ${PROJECT_SOURCE_DIR}/libs/temp/gtest
    SOURCE_DIR ${PROJECT_SOURCE_DIR}/libs/temp/gtest/src/gtest
    BINARY_DIR ${PROJECT_SOURCE_DIR}/libs/temp/gtest/src/gtest
    # googletest 의 경우 install prefix /usr/local 로 고정. 
    # 별도의 prefix 설정 없음.
    # gtest 의 include 참조는 source direcotory 의 include directory 참조
    # library 의 참조는 build(binary) directory 를 참조
    INSTALL_COMMAND ""
  )
  ExternalProject_Get_Property ( ${_external_name} source_dir binary_dir )
  SET ( libgtest_LIBRARIES
        "${binary_dir}/googlemock/gtest/libgtest.a" PARENT_SCOPE )
  SET ( libgtest_INCLUDE_DIRS "${source_dir}/googletest/include" PARENT_SCOPE )
ENDFUNCTION ()
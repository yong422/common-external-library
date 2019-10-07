# find libopenssl
#
# exports:
#
#
#   libopenssl_FOUND
#   libopenssl_INCLUDE_DIRS
#   libopenssl_LIBRARIES 
#   libopenssl_ssl_LIBRARY  : libssl.a
#   libopenssl_crypto_LIBRARY : libcrypto.a
#
#
#   find cmake 파일 상세주석은 Findlibz.cmake 참조

INCLUDE ( FindPkgConfig )
INCLUDE ( FindPackageHandleStandardArgs )

SET ( libopenssl_INSTALL_PATH ${PROJECT_SOURCE_DIR}/libs/temp/openssl/build )

FIND_PATH ( libopenssl_INCLUDE_DIR
            NAMES openssl/opensslconf.h openssl/opensslv.h
            PATHS ${libopenssl_INSTALL_PATH}/include NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

FIND_LIBRARY ( libopenssl_ssl_LIBRARY
               NAMES libssl.a
               PATHS ${libopenssl_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )
FIND_LIBRARY ( libopenssl_crypto_LIBRARY
               NAMES libcrypto.a
               PATHS ${libopenssl_INSTALL_PATH}/lib NO_DEFAULT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_ENVIRONMENT_PATH )

FIND_PACKAGE_HANDLE_STANDARD_ARGS ( libopenssl DEFAULT_MSG libopenssl_INCLUDE_DIR 
                                    libopenssl_ssl_LIBRARY libopenssl_crypto_LIBRARY )

IF (( ${libopenssl_INCLUDE_DIR} STREQUAL "libopenssl_INCLUDE_DIR-NOTFOUND" ) OR
    ( ${libopenssl_ssl_LIBRARY} STREQUAL "libopenssl_ssl_LIBRARY-NOTFOUND" ) OR
    ( ${libopenssl_crypto_LIBRARY} STREQUAL "libopenssl_crypto_LIBRARY-NOTFOUND" ))
  SET ( libopenssl_FOUND no )
ELSE ()
  SET ( libopenssl_FOUND yes )
ENDIF ()

IF ( libopenssl_FOUND )
  MESSAGE ( "${ColorGreen}Found OpenSSL${ColorEnd}" )
  SET ( libopenssl_LIBRARIES ${libopenssl_ssl_LIBRARY} ${libopenssl_crypto_LIBRARY} )
  SET ( libopenssl_INCLUDE_DIRS ${libopenssl_INCLUDE_DIR} )
ELSE ()
  MESSAGE ( "${ColorRed}Not Found OpenSSL${ColorEnd}" )
  SET ( libopenssl_LIBRARIES )
  SET ( libopenssl_INCLUDE_DIRS )
ENDIF ()

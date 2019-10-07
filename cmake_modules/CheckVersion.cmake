#
# Copyright (c) 2019, Yongkyu Jo
# All rights reserved.
#
# version 체크

#
# @function VERSION_STRING_TO_VERSION_LIST
# @param    _version_string       parsing 하기 위한 semantic version major.minor.patch
# @param    _version_list         version number list 를 받기위한 결과 변수
# @param    _version_list_length  version number list 의 length (semantic version = 3)
#
# @example
#           VERSION_STRING_TO_VERSION_LIST ( "1.2.3" MY_VERSION_LIST MY_VERSION_LIST_LENGTH )
#           ${MY_VERSION_LIST} => "1;2;3"
#           ${MY_VERSION_LIST_LENGTH} => 3
FUNCTION ( VERSION_STRING_TO_VERSION_LIST _version_string _version_list _version_list_length )
  STRING ( REPLACE "." ";" MY_VERSION_LIST ${_version_string} )
  LIST ( LENGTH MY_VERSION_LIST MY_VERSION_LIST_LENGTH )
  SET ( ${_version_list} ${MY_VERSION_LIST} PARENT_SCOPE )
  SET ( ${_version_list_length} ${MY_VERSION_LIST_LENGTH} )
ENDFUNCTION ()

#
# @function GET_VERSION_NUMBER
# @param    _version_number_type  semantic version 에서 가져올 version number type 
#                                 [MAJOR, MINOR, PATCH]
# @param    _version_string       parsing 하기 위한 semantic version major.minor.patch
# @param    _result               결과값으로 저장할 변수
#
# @example
#           GET_VERSION_NUMBER ( "MAJOR" 3.4.5 MY_MAJOR_NUMBER )
#           ${MY_MAJOR_NUMBER} => 3
#
#           GET_VERSION_NUMBER ( "MINOR" 3.4.5 MY_MINOR_NUMBER )
#           ${MY_MINOR_NUMBER} => 4
#
FUNCTION ( GET_VERSION_NUMBER _version_number_type _version_string _result )
  VERSION_STRING_TO_VERSION_LIST ( ${_version_string} MY_VERSION_LIST MY_VERSION_LIST_LENGTH )
  IF ( MY_VERSION_LIST_LENGTH LESS 3 )
    MESSAGE ( FATAL_ERROR "need semantic version x.x.x" )
  ENDIF ()

  IF ( _version_number_type STREQUAL "MAJOR" )
    LIST ( GET MY_VERSION_LIST 0 MY_VERSION_MAJOR )
    SET ( ${_result} ${MY_VERSION_MAJOR} PARENT_SCOPE )
  ELSEIF ( _version_number_type STREQUAL "MINOR" )
    LIST ( GET MY_VERSION_LIST 1 MY_VERSION_MICOR )
    SET ( ${_result} ${MY_VERSION_MICOR} PARENT_SCOPE )
  ELSEIF ( _version_number_type STREQUAL "PATCH" )
    LIST ( GET MY_VERSION_LIST 2 MY_VERSION_PATCH )
    SET ( ${_result} ${MY_VERSION_PATCH} PARENT_SCOPE )
  ELSE ()
    MESSAGE ( FATAL_ERROR "GET_VERSION_NUMBER support type [MAJOR, MINOR, PATCH]" )
  ENDIF ()
ENDFUNCTION ()

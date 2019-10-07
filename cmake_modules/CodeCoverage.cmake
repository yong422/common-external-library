# Copyright (c) 2012 - 2017, Lars Bilke
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# 2012-01-31, Lars Bilke
# - Enable Code Coverage
#
# 2013-09-17, Joakim Söderberg
# - Added support for Clang.
# - Some additional usage instructions.
#
# 2016-02-03, Lars Bilke
# - Refactored functions to use named parameters
#
# 2017-06-02, Lars Bilke
# - Merged with modified version from github.com/ufz/ogs
#
# 2019-02-20, Yongkyu Jo
# - gitlab-ci coverage 연동을 위한 gcovr arguments 수정 및 function 수정
# - 기타 message 추가
#
# USAGE:

# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#   INCLUDE(CodeCoverage)
#
# 3. Append necessary compiler flags:
#   APPEND_COVERAGE_COMPILER_FLAGS()
#  
# 4. Use the function SETUP_TARGET_FOR_COVERAGE to create a custom make target
#    which runs your test executable and produces a lcov code coverage report:
#    Example:
#   SETUP_TARGET_FOR_COVERAGE(
#        my_coverage_target  # Name for custom target.
#        test_driver         # Name of the test driver executable that runs the tests.
#                  # NOTE! This should always have a ZERO as exit code
#                  # otherwise the coverage generation will not complete.
#        coverage            # Name of output directory.
#        )
#
# 5. Build a Debug build:
#   cmake -DCMAKE_BUILD_TYPE=Debug ..
#   make
#   make my_coverage_target
#
#

# Check prereqs
FIND_PROGRAM ( GCOV_PATH gcov )
FIND_PROGRAM ( LCOV_PATH lcov )
FIND_PROGRAM ( GENHTML_PATH genhtml )
FIND_PROGRAM ( GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests )
# 참조 https://cmake.org/cmake/help/v3.0/module/FindPythonLibs.html
# FindPython 의 경우 cmake 3.10 이상부터 지원되므로 3.4 를 이용하는 현재에는 사용 불가.
# 그 이하 버전에서는 FindPythonInterp 와 FindPythonLibs 를 필요에 맞게 사용한다.
FIND_PACKAGE ( PythonInterp )

IF ( NOT GCOV_PATH )
  MESSAGE ( FATAL_ERROR "gcov not found! Aborting..." )
ENDIF() # NOT GCOV_PATH

IF ( NOT CMAKE_COMPILER_IS_GNUCXX )
  # Clang version 3.0.0 and greater now supports gcov as well.
  MESSAGE ( WARNING "Compiler is not GNU gcc! Clang Version 3.0.0 and greater supports gcov as well, but older versions don't." )
  
  IF ( NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" )
    MESSAGE ( FATAL_ERROR "Compiler is not GNU gcc! Aborting..." )
  ENDIF ()
ENDIF () # NOT CMAKE_COMPILER_IS_GNUCXX

SET ( COVERAGE_COMPILER_FLAGS "-g --coverage -fprofile-arcs -ftest-coverage"
    CACHE INTERNAL "" )
SET ( CMAKE_CXX_FLAGS_COVERAGE
     ${COVERAGE_COMPILER_FLAGS}
     CACHE STRING "Flags used by the C++ compiler during coverage builds."
     FORCE )
SET ( CMAKE_C_FLAGS_COVERAGE
     ${COVERAGE_COMPILER_FLAGS}
     CACHE STRING "Flags used by the C compiler during coverage builds."
     FORCE )
SET ( CMAKE_EXE_LINKER_FLAGS_COVERAGE
     ""
     CACHE STRING "Flags used for linking binaries during coverage builds."
    FORCE )
SET ( CMAKE_SHARED_LINKER_FLAGS_COVERAGE
     ""
     CACHE STRING "Flags used by the shared libraries linker during coverage builds."
     FORCE )
MARK_AS_ADVANCED (
    CMAKE_CXX_FLAGS_COVERAGE
    CMAKE_C_FLAGS_COVERAGE
    CMAKE_EXE_LINKER_FLAGS_COVERAGE
    CMAKE_SHARED_LINKER_FLAGS_COVERAGE )

IF ( NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
  MESSAGE( WARNING "Code coverage results with an optimized (non-Debug) build may be misleading" )
ENDIF() # NOT CMAKE_BUILD_TYPE STREQUAL "Debug"


# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests.
#                       MUST return ZERO always, even on errors. 
#                       If not, no coverage report will be created!
# Param _outputname     lcov output is generated as _outputname.info
#                       HTML report is generated in _outputname/index.html
# Optional fourth parameter is passed as arguments to _testrunner
#   Pass them in list form, e.g.: "-j;2" for -j 2
FUNCTION ( SETUP_TARGET_FOR_COVERAGE _targetname _testrunner _outputname )

  IF (NOT LCOV_PATH )
    MESSAGE ( FATAL_ERROR "lcov not found! Aborting..." )
  ELSE ()
    MESSAGE ( STATUS "Found Tool: ${LCOV_PATH}")
  ENDIF ()
  IF ( NOT GENHTML_PATH )
    MESSAGE ( FATAL_ERROR "genhtml not found! Aborting..." )
  ELSE ()
    MESSAGE ( STATUS "Found Tool: ${GENHTML_PATH}")
  ENDIF ()
  IF ( NOT PYTHONINTERP_FOUND )
    MESSAGE ( FATAL_ERROR "python not found! Aborting..." )
  ELSE ()
    MESSAGE ( STATUS "Found Packages: python v${PYTHON_VERSION_STRING}" )
    MESSAGE ( STATUS "Found Tool: ${PYTHON_EXECUTABLE}" )
  ENDIF ()
  IF ( NOT GCOVR_PATH )
    MESSAGE ( FATAL_ERROR "gcovr not found! Aborting..." )
  ELSE ()
    MESSAGE ( STATUS "Found Tool: ${GCOVR_PATH}")
  ENDIF ()
  
  # Setup target
  ADD_CUSTOM_TARGET ( ${_targetname}
    # Cleanup lcov
    ${LCOV_PATH} --directory . --zerocounters
    # Run tests
    COMMAND ${_testrunner} ${ARGV3}
    # Running gcovr
    # 변경. code coverage 분석용은 lcov 생성된 html 문서를 확인한다.
    # gcovr 을 이용한 code coverage 체크는 gitlab-ci 연동 전체 코드 커버리지의 퍼센티지 참조.
    COMMAND ${GCOVR_PATH} --gcov-ignore-parse-errors -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/' -e '${CMAKE_SOURCE_DIR}/build/'
    # Capturing lcov counters and generating report
    COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_outputname}.info
    COMMAND ${LCOV_PATH} --remove ${_outputname}.info 'build/*' 'tests/*' '/usr/*' --output-file ${_outputname}.info.cleaned
    COMMAND ${GENHTML_PATH} -o ${_outputname} ${_outputname}.info.cleaned
    COMMAND ${CMAKE_COMMAND} -E remove ${_outputname}.info ${_outputname}.info.cleaned

    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
  )
  # Show info where to find the report
  ADD_CUSTOM_COMMAND(TARGET ${_targetname} POST_BUILD
    COMMAND ;
    COMMENT "Open ./${_outputname}/index.html in your browser to view the coverage report."
  )
ENDFUNCTION()

FUNCTION ( APPEND_COVERAGE_COMPILER_FLAGS )
    SET ( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${COVERAGE_COMPILER_FLAGS}" PARENT_SCOPE)
    message(STATUS "Appending code coverage compiler debug flags: ${COVERAGE_COMPILER_FLAGS}")
endfunction() # APPEND_COVERAGE_COMPILER_FLAGS